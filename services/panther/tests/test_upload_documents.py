import json
import logging
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

from panther.document_source import (
    LocalDocumentSource,
    MonaDocumentSource,
    create_document_source,
)
from panther.mona_client import MonaClient
from panther.models.generated.full_text import FullText
from panther.upload_documents import UploadCancelledError, build_action, execute_upload

_PREVIOUS_LOGGING_DISABLE = logging.root.manager.disable


def setUpModule() -> None:
    logging.disable(logging.CRITICAL)


def tearDownModule() -> None:
    logging.disable(_PREVIOUS_LOGGING_DISABLE)


class _FakeEsClient:
    def __init__(self):
        self.closed = False

    def ping(self) -> bool:
        return True

    def close(self) -> None:
        self.closed = True


class DocumentSourceFactoryTests(unittest.TestCase):
    def test_create_document_source_requires_one_input(self):
        with self.assertRaisesRegex(ValueError, "Either DATA_ROOT or MONA_URL"):
            create_document_source()

    def test_create_document_source_prefers_data_root_when_both_are_given(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            source = create_document_source(
                data_root=Path(tmpdir),
                mona_url="http://mona.example",
            )

        self.assertEqual(source.source, "local")


class DocumentSourceTests(unittest.TestCase):
    def test_local_document_source_requires_existing_directory(self):
        with self.assertRaisesRegex(FileNotFoundError, "Data root not found"):
            LocalDocumentSource(data_root=Path("/tmp/panther-missing-source"))

    def test_local_document_source_counts_full_text_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "doc-1").mkdir()
            (root / "doc-2").mkdir()
            (root / "doc-1" / "full-text.json").write_text(
                json.dumps(
                    {
                        "docId": "JP-1",
                        "task": "example-task",
                        "kind": "publication",
                        "extension": "json",
                        "applicants": [],
                        "law": "patent",
                        "documentName": "Example JP-1",
                        "documentCode": "DOC-001",
                    }
                ),
                encoding="utf-8",
            )
            (root / "doc-2" / "full-text.json").write_text(
                json.dumps(
                    {
                        "docId": "JP-2",
                        "task": "example-task",
                        "kind": "publication",
                        "extension": "json",
                        "applicants": [],
                        "law": "patent",
                        "documentName": "Example JP-2",
                        "documentCode": "DOC-002",
                    }
                ),
                encoding="utf-8",
            )

            source = LocalDocumentSource(data_root=root)

            self.assertEqual(source.doc_count(), 2)

    def test_local_document_source_filters_by_id_list(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            for doc_id in ("JP-1", "JP-2"):
                doc_dir = root / doc_id
                doc_dir.mkdir()
                (doc_dir / "full-text.json").write_text(
                    json.dumps(
                        {
                            "docId": doc_id,
                            "task": "example-task",
                            "kind": "publication",
                            "extension": "json",
                            "applicants": [],
                            "law": "patent",
                            "documentName": f"Example {doc_id}",
                            "documentCode": doc_id,
                        }
                    ),
                    encoding="utf-8",
                )

            source = LocalDocumentSource(data_root=root)

            self.assertEqual(source.doc_count(id_list=["JP-2"]), 1)
            full_texts = list(source.iter_full_texts(id_list=["JP-2"]))
            self.assertEqual([item.docId for item in full_texts], ["JP-2"])

    def test_local_document_source_prefers_index_lookup_for_id_list(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            for doc_id in ("JP-1", "JP-2"):
                doc_dir = root / doc_id
                doc_dir.mkdir()
                (doc_dir / "full-text.json").write_text(
                    json.dumps(
                        {
                            "docId": doc_id,
                            "task": "example-task",
                            "kind": "publication",
                            "extension": "json",
                            "applicants": [],
                            "law": "patent",
                            "documentName": f"Example {doc_id}",
                            "documentCode": doc_id,
                        }
                    ),
                    encoding="utf-8",
                )

            source = LocalDocumentSource(data_root=root)
            source._get_full_text_index()
            with patch("pathlib.Path.rglob", side_effect=AssertionError("rglob should not be used after indexing")):
                self.assertEqual(source.doc_count(id_list=["JP-2"]), 1)
                full_texts = list(source.iter_full_texts(id_list=["JP-2"]))

            self.assertEqual([item.docId for item in full_texts], ["JP-2"])

    def test_local_document_source_raises_upload_cancelled_error(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "doc-1").mkdir()
            (root / "doc-1" / "full-text.json").write_text("{}", encoding="utf-8")
            source = LocalDocumentSource(data_root=root)

            with self.assertRaises(UploadCancelledError):
                list(source.iter_full_texts(should_cancel=lambda: True))

    def test_mona_document_source_exposes_mona_source_name(self):
        source = MonaDocumentSource(mona_client=MonaClient("http://mona.example"))

        self.assertEqual(source.source, "mona-api")

    def test_mona_document_source_counts_documents_from_client(self):
        client = MonaClient("http://mona.example")
        client.list_document_ids = MagicMock(return_value=["JP-1", "JP-2", "JP-3"])
        source = MonaDocumentSource(mona_client=client)

        self.assertEqual(source.doc_count(), 3)

    def test_mona_document_source_filters_by_id_list(self):
        client = MonaClient("http://mona.example")
        client.list_document_ids = MagicMock(return_value=["JP-1", "JP-2", "JP-3"])
        client.get_full_text = MagicMock(
            side_effect=[
                FullText(
                    docId="JP-2",
                    task="example-task",
                    kind="publication",
                    extension="json",
                    applicants=[],
                    law="patent",
                    documentName="Example Document 2",
                    documentCode="DOC-002",
                )
            ]
        )
        source = MonaDocumentSource(mona_client=client)

        self.assertEqual(source.doc_count(id_list=["JP-2", "JP-9"]), 1)
        full_texts = list(source.iter_full_texts(id_list=["JP-2", "JP-9"]))
        self.assertEqual([item.docId for item in full_texts], ["JP-2"])
        client.get_full_text.assert_called_once_with("JP-2")

    def test_mona_document_source_reuses_cached_document_ids(self):
        client = MonaClient("http://mona.example")
        client.list_document_ids = MagicMock(return_value=["JP-1", "JP-2"])
        client.get_full_text = MagicMock(
            side_effect=[
                FullText(
                    docId="JP-1",
                    task="example-task",
                    kind="publication",
                    extension="json",
                    applicants=[],
                    law="patent",
                    documentName="Example Document 1",
                    documentCode="DOC-001",
                ),
                FullText(
                    docId="JP-2",
                    task="example-task",
                    kind="publication",
                    extension="json",
                    applicants=[],
                    law="patent",
                    documentName="Example Document 2",
                    documentCode="DOC-002",
                ),
            ]
        )
        source = MonaDocumentSource(mona_client=client)

        count = source.doc_count()
        full_texts = list(source.iter_full_texts())

        self.assertEqual(count, 2)
        self.assertEqual(len(full_texts), 2)
        client.list_document_ids.assert_called_once_with()


class BuildActionTests(unittest.TestCase):
    def test_build_action_uses_doc_as_upsert_when_hash_guard_disabled(self):
        full_text = FullText(
            docId="JP-123",
            task="example-task",
            kind="publication",
            extension="json",
            applicants=[],
            law="patent",
            documentName="Example Document",
            documentCode="DOC-001",
        )

        action = build_action(
            index="patent-documents",
            full_text=full_text,
            use_hash_guard=False,
        )

        self.assertEqual(action["_id"], "JP-123")
        self.assertEqual(action["_index"], "patent-documents")
        self.assertTrue(action["doc_as_upsert"])
        self.assertIn("doc", action)

    def test_build_action_uses_scripted_upsert_when_hash_guard_enabled(self):
        full_text = FullText(
            docId="JP-123",
            task="example-task",
            kind="publication",
            extension="json",
            applicants=[],
            law="patent",
            documentName="Example Document",
            documentCode="DOC-001",
        )

        action = build_action(
            index="patent-documents",
            full_text=full_text,
            use_hash_guard=True,
        )

        self.assertEqual(action["_id"], "JP-123")
        self.assertTrue(action["scripted_upsert"])
        self.assertIn("script", action)
        self.assertIn("upsert", action)


class ExecuteUploadTests(unittest.TestCase):
    @patch("panther.upload_documents.bulk_upsert_with_retries")
    @patch.object(MonaDocumentSource, "iter_full_texts")
    def test_execute_upload_uses_document_source_with_mona_client(
        self,
        iter_full_texts,
        bulk_upsert_with_retries,
    ):
        es = _FakeEsClient()
        source = MonaDocumentSource(mona_client=MonaClient("http://mona.example"))
        iter_full_texts.return_value = [
            FullText(
                docId="JP-1",
                task="example-task",
                kind="publication",
                extension="json",
                applicants=[],
                law="patent",
                documentName="Example Document",
                documentCode="DOC-001",
            )
        ]
        bulk_upsert_with_retries.return_value = (1, 0)

        result = execute_upload(
            es=es,
            index="patent-documents",
            source=source,
        )

        iter_full_texts.assert_called_once_with(should_cancel=None, id_list=None)
        self.assertEqual(result.source, "mona-api")
        self.assertIsNone(result.requested_ids)
        self.assertEqual(result.missing_ids, [])
        self.assertEqual(result.total, 1)
        self.assertTrue(es.closed)

    @patch("panther.upload_documents.bulk_upsert_with_retries")
    @patch.object(LocalDocumentSource, "iter_full_texts")
    def test_execute_upload_uses_document_source_with_data_root(
        self,
        iter_full_texts,
        bulk_upsert_with_retries,
    ):
        es = _FakeEsClient()
        with tempfile.TemporaryDirectory() as tmpdir:
            source = LocalDocumentSource(data_root=Path(tmpdir))
            iter_full_texts.return_value = [
                FullText(
                    docId="JP-1",
                    task="example-task",
                    kind="publication",
                    extension="json",
                    applicants=[],
                    law="patent",
                    documentName="Example Document",
                    documentCode="DOC-001",
                )
            ]
            bulk_upsert_with_retries.return_value = (1, 0)

            result = execute_upload(
                es=es,
                index="patent-documents",
                source=source,
            )

        iter_full_texts.assert_called_once_with(should_cancel=None, id_list=None)
        self.assertEqual(result.source, "local")
        self.assertIsNone(result.requested_ids)
        self.assertEqual(result.missing_ids, [])
        self.assertEqual(result.total, 1)
        self.assertTrue(es.closed)

    @patch("panther.upload_documents.bulk_upsert_with_retries")
    @patch.object(LocalDocumentSource, "missing_ids", return_value=["JP-9"])
    @patch.object(LocalDocumentSource, "iter_full_texts")
    def test_execute_upload_passes_id_list_to_source(
        self,
        iter_full_texts,
        missing_ids,
        bulk_upsert_with_retries,
    ):
        es = _FakeEsClient()
        with tempfile.TemporaryDirectory() as tmpdir:
            source = LocalDocumentSource(data_root=Path(tmpdir))
            iter_full_texts.return_value = []
            bulk_upsert_with_retries.return_value = (0, 0)

            result = execute_upload(
                es=es,
                index="patent-documents",
                source=source,
                id_list=["JP-2"],
            )

        missing_ids.assert_called_once_with(id_list=["JP-2"])
        iter_full_texts.assert_called_once_with(
            should_cancel=None,
            id_list=["JP-2"],
        )
        self.assertEqual(result.requested_ids, ["JP-2"])
        self.assertEqual(result.missing_ids, ["JP-9"])

    @patch("panther.upload_documents.bulk_upsert_with_retries")
    @patch.object(LocalDocumentSource, "iter_full_texts")
    def test_execute_upload_reports_progress_updates(
        self,
        iter_full_texts,
        bulk_upsert_with_retries,
    ):
        es = _FakeEsClient()
        progress_updates = []
        with tempfile.TemporaryDirectory() as tmpdir:
            source = LocalDocumentSource(data_root=Path(tmpdir))
            iter_full_texts.return_value = [
                FullText(
                    docId="JP-1",
                    task="example-task",
                    kind="publication",
                    extension="json",
                    applicants=[],
                    law="patent",
                    documentName="Example Document",
                    documentCode="DOC-001",
                ),
                FullText(
                    docId="JP-2",
                    task="example-task",
                    kind="publication",
                    extension="json",
                    applicants=[],
                    law="patent",
                    documentName="Example Document 2",
                    documentCode="DOC-002",
                ),
            ]

            def fake_bulk(*args, **kwargs):
                kwargs["on_progress"](1, 0)
                kwargs["on_progress"](2, 0)
                return (2, 0)

            bulk_upsert_with_retries.side_effect = fake_bulk

            result = execute_upload(
                es=es,
                index="patent-documents",
                source=source,
                on_progress=progress_updates.append,
            )

        self.assertEqual(
            [(item.total, item.success, item.failed) for item in progress_updates],
            [(2, 0, 0), (2, 1, 0), (2, 2, 0)],
        )
        self.assertEqual(result.total, 2)
        self.assertEqual(result.success, 2)
        self.assertIsNone(result.requested_ids)
        self.assertEqual(result.missing_ids, [])


if __name__ == "__main__":
    unittest.main()
