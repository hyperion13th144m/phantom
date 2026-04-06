import json
from typing import Any
from urllib.parse import quote, urljoin, urlparse
from urllib.request import urlopen

from panther.models.generated.bibliographic_items import BibliographicItems
from panther.models.generated.full_text import FullText
from panther.models.generated.images_information import ImagesInformation


class MonaClient:
    def __init__(self, base_url: str):
        normalized_base_url = base_url.rstrip("/")
        parsed = urlparse(normalized_base_url)
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError(f"Invalid Mona base URL: {base_url}")
        self.base_url = normalized_base_url

    def list_document_ids(self) -> list[str]:
        payload = self._load_json("/documents/idList")
        doc_ids = json.loads(payload) if isinstance(payload, str) else payload
        if not isinstance(doc_ids, list):
            raise ValueError("mona /documents/idList response must be list[str]")
        return [str(doc_id) for doc_id in doc_ids]

    def get_document_content(self, doc_id: str) -> list[dict[str, Any]]:
        payload = self._load_json(self._document_endpoint(doc_id, "/json/content"))
        if not isinstance(payload, list):
            raise ValueError(
                "mona /documents/{doc_id}/json/content response must be a JSON array"
            )
        return payload

    def get_images_information(self, doc_id: str) -> ImagesInformation:
        payload = self._load_json(
            self._document_endpoint(doc_id, "/json/images-information")
        )
        return ImagesInformation(**payload)

    def get_bibliographic_items(self, doc_id: str) -> BibliographicItems:
        payload = self._load_json(
            self._document_endpoint(doc_id, "/json/bibliographic-items")
        )
        return BibliographicItems(**payload)

    def get_full_text(self, doc_id: str) -> FullText:
        payload = self._load_json(self._document_endpoint(doc_id, "/json/full-text"))
        return FullText(**payload)

    def get_image(self, doc_id: str, file_name: str) -> bytes:
        encoded_doc_id = quote(doc_id, safe="")
        encoded_file_name = quote(file_name, safe="")
        return self._load_bytes(f"/documents/{encoded_doc_id}/images/{encoded_file_name}")

    def _document_endpoint(self, doc_id: str, suffix: str) -> str:
        encoded_doc_id = quote(doc_id, safe="")
        return f"/documents/{encoded_doc_id}{suffix}"

    def _load_json(self, endpoint: str) -> Any:
        return json.loads(self._load_bytes(endpoint).decode("utf-8"))

    def _load_bytes(self, endpoint: str) -> bytes:
        url = urljoin(self.base_url + "/", endpoint.lstrip("/"))
        with urlopen(url) as response:
            return response.read()
