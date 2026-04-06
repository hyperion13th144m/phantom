import json
import logging
import traceback
from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass, field
from pathlib import Path
from typing import Protocol

from panther.mona_client import MonaClient
from panther.models.generated.full_text import FullText
from panther.upload_documents import UploadCancelledError

logger = logging.getLogger(__name__)


class DocumentSource(Protocol):
    @property
    def source(self) -> str: ...

    @property
    def label(self) -> str: ...

    def doc_count(self, id_list: Sequence[str] | None = None) -> int: ...

    def missing_ids(self, id_list: Sequence[str] | None = None) -> list[str]: ...

    def iter_full_texts(
        self,
        should_cancel: Callable[[], bool] | None = None,
        id_list: Sequence[str] | None = None,
    ) -> Iterable[FullText]: ...


@dataclass(frozen=True)
class LocalDocumentSource:
    data_root: Path
    _full_text_index_cache: dict[str, Path] | None = field(
        default=None,
        init=False,
        repr=False,
        compare=False,
    )

    def __post_init__(self) -> None:
        if not self.data_root.exists():
            raise FileNotFoundError(f"Data root not found: {self.data_root}")

    @property
    def source(self) -> str:
        return "local"

    @property
    def label(self) -> str:
        return str(self.data_root)

    def _wanted_doc_ids(self, id_list: Sequence[str] | None) -> tuple[str, ...] | None:
        if not id_list:
            return None
        return tuple(str(doc_id) for doc_id in id_list)

    def _build_full_text_index(self) -> dict[str, Path]:
        index: dict[str, Path] = {}
        for full_text_path in self.data_root.rglob("full-text.json"):
            doc_id = full_text_path.parent.name
            if doc_id in index:
                logger.warning(
                    "Duplicate local document id %s found at %s; keeping %s",
                    doc_id,
                    full_text_path,
                    index[doc_id],
                )
                continue
            index[doc_id] = full_text_path
        return index

    def _get_full_text_index(self) -> dict[str, Path]:
        if self._full_text_index_cache is None:
            object.__setattr__(self, "_full_text_index_cache", self._build_full_text_index())
        if self._full_text_index_cache is None:
            return {}
        return self._full_text_index_cache

    def _get_indexed_path(self, doc_id: str) -> Path | None:
        return self._get_full_text_index().get(doc_id)

    def _iter_selected_paths(
        self,
        id_list: Sequence[str] | None = None,
    ) -> Iterable[tuple[str, Path]]:
        wanted_doc_ids = self._wanted_doc_ids(id_list)
        if wanted_doc_ids is None:
            for doc_id, full_text_path in self._get_full_text_index().items():
                yield doc_id, full_text_path
            return
        for doc_id in wanted_doc_ids:
            full_text_path = self._get_indexed_path(doc_id)
            if full_text_path is not None:
                yield doc_id, full_text_path

    def doc_count(self, id_list: Sequence[str] | None = None) -> int:
        return sum(1 for _ in self._iter_selected_paths(id_list=id_list))

    def missing_ids(self, id_list: Sequence[str] | None = None) -> list[str]:
        wanted_doc_ids = self._wanted_doc_ids(id_list)
        if wanted_doc_ids is None:
            return []
        return [doc_id for doc_id in wanted_doc_ids if self._get_indexed_path(doc_id) is None]

    def _iter_matching_full_texts(
        self,
        should_cancel: Callable[[], bool] | None = None,
        id_list: Sequence[str] | None = None,
    ) -> Iterable[FullText]:
        for doc_id, full_text_path in self._iter_selected_paths(id_list=id_list):
            if should_cancel and should_cancel():
                raise UploadCancelledError("Upload was cancelled before completion")
            try:
                payload = json.loads(full_text_path.read_text(encoding="utf-8"))
                full_text = FullText(**payload)
                if full_text.docId != doc_id:
                    logger.warning(
                        "Local document id mismatch for %s: payload docId=%s",
                        full_text_path,
                        full_text.docId,
                    )
                yield full_text
            except UploadCancelledError:
                raise
            except Exception as exc:
                logger.error("[ERROR] %s: %s", full_text_path, exc)
                logger.error(traceback.format_exc())
                continue

    def iter_full_texts(
        self,
        should_cancel: Callable[[], bool] | None = None,
        id_list: Sequence[str] | None = None,
    ) -> Iterable[FullText]:
        yield from self._iter_matching_full_texts(
            should_cancel=should_cancel,
            id_list=id_list,
        )


@dataclass(frozen=True)
class MonaDocumentSource:
    mona_client: MonaClient
    _doc_ids_cache: tuple[str, ...] | None = field(
        default=None,
        init=False,
        repr=False,
        compare=False,
    )

    @property
    def source(self) -> str:
        return "mona-api"

    @property
    def label(self) -> str:
        return self.mona_client.base_url

    def _get_doc_ids(self) -> tuple[str, ...]:
        if self._doc_ids_cache is None:
            object.__setattr__(
                self,
                "_doc_ids_cache",
                tuple(str(doc_id) for doc_id in self.mona_client.list_document_ids()),
            )
        if self._doc_ids_cache is None:
            return ()
        return self._doc_ids_cache

    def _filter_doc_ids(self, id_list: Sequence[str] | None = None) -> tuple[str, ...]:
        doc_ids = self._get_doc_ids()
        if not id_list:
            return doc_ids
        wanted_doc_ids = {str(doc_id) for doc_id in id_list}
        return tuple(doc_id for doc_id in doc_ids if doc_id in wanted_doc_ids)

    def doc_count(self, id_list: Sequence[str] | None = None) -> int:
        return len(self._filter_doc_ids(id_list=id_list))

    def missing_ids(self, id_list: Sequence[str] | None = None) -> list[str]:
        wanted_doc_ids = self._wanted_doc_ids(id_list)
        if wanted_doc_ids is None:
            return []
        available_doc_ids = set(self._get_doc_ids())
        return [doc_id for doc_id in wanted_doc_ids if doc_id not in available_doc_ids]

    def _wanted_doc_ids(self, id_list: Sequence[str] | None) -> tuple[str, ...] | None:
        if not id_list:
            return None
        return tuple(str(doc_id) for doc_id in id_list)

    def iter_full_texts(
        self,
        should_cancel: Callable[[], bool] | None = None,
        id_list: Sequence[str] | None = None,
    ) -> Iterable[FullText]:
        for doc_id in self._filter_doc_ids(id_list=id_list):
            if should_cancel and should_cancel():
                raise UploadCancelledError("Upload was cancelled before completion")
            try:
                yield self.mona_client.get_full_text(doc_id)
            except Exception as exc:
                logger.error("[ERROR] doc_id=%s: %s", doc_id, exc)
                continue


def create_document_source(
    data_root: Path | None = None,
    mona_url: str | None = None,
) -> DocumentSource:
    if data_root is not None:
        if mona_url:
            logger.warning(
                "Both MONA_URL and DATA_ROOT provided. DATA_ROOT is used. MONA_URL is ignored."
            )
        return LocalDocumentSource(data_root=data_root)
    if mona_url:
        return MonaDocumentSource(mona_client=MonaClient(mona_url))
    raise ValueError("Either DATA_ROOT or MONA_URL must be provided.")
