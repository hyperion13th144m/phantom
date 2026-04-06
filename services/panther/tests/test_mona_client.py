import json
import unittest
from unittest.mock import patch

from panther.mona_client import MonaClient


class _FakeResponse:
    def __init__(self, payload: object):
        if isinstance(payload, bytes):
            self._payload = payload
        else:
            self._payload = json.dumps(payload).encode("utf-8")

    def read(self) -> bytes:
        return self._payload

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        return None


class MonaClientTests(unittest.TestCase):
    def test_rejects_invalid_base_url(self):
        with self.assertRaisesRegex(ValueError, "Invalid Mona base URL"):
            MonaClient("mona.example")

    @patch("panther.mona_client.urlopen")
    def test_list_document_ids_uses_documents_idlist_endpoint(self, mock_urlopen):
        mock_urlopen.return_value = _FakeResponse(["JP-1", "JP-2"])

        client = MonaClient("http://mona.example/api")

        doc_ids = client.list_document_ids()

        self.assertEqual(doc_ids, ["JP-1", "JP-2"])
        mock_urlopen.assert_called_once_with(
            "http://mona.example/api/documents/idList"
        )

    @patch("panther.mona_client.urlopen")
    def test_get_document_content_uses_content_endpoint(self, mock_urlopen):
        mock_urlopen.return_value = _FakeResponse([{"page": 1, "blocks": []}])

        client = MonaClient("http://mona.example")
        content = client.get_document_content("JP/123")

        self.assertEqual(content, [{"page": 1, "blocks": []}])
        mock_urlopen.assert_called_once_with(
            "http://mona.example/documents/JP%2F123/json/content"
        )

    @patch("panther.mona_client.urlopen")
    def test_get_bibliographic_items_uses_bibliographic_endpoint(self, mock_urlopen):
        mock_urlopen.return_value = _FakeResponse(
            {
                "docId": "JP-123",
                "task": "example-task",
                "kind": "publication",
                "extension": "json",
                "applicants": [],
                "law": "patent",
                "documentName": "Example Document",
                "documentCode": "DOC-001",
            }
        )

        client = MonaClient("http://mona.example")
        items = client.get_bibliographic_items("JP/123")

        self.assertEqual(items.docId, "JP-123")
        mock_urlopen.assert_called_once_with(
            "http://mona.example/documents/JP%2F123/json/bibliographic-items"
        )

    @patch("panther.mona_client.urlopen")
    def test_get_full_text_uses_documents_full_text_endpoint(self, mock_urlopen):
        mock_urlopen.return_value = _FakeResponse(
            {
                "docId": "JP-123",
                "task": "example-task",
                "kind": "publication",
                "extension": "json",
                "applicants": [],
                "law": "patent",
                "documentName": "Example Document",
                "documentCode": "DOC-001",
            }
        )

        client = MonaClient("http://mona.example")
        full_text = client.get_full_text("JP/123")

        self.assertEqual(full_text.docId, "JP-123")
        mock_urlopen.assert_called_once_with(
            "http://mona.example/documents/JP%2F123/json/full-text"
        )

    @patch("panther.mona_client.urlopen")
    def test_get_image_uses_image_endpoint(self, mock_urlopen):
        mock_urlopen.return_value = _FakeResponse(b"image-bytes")

        client = MonaClient("http://mona.example")
        image = client.get_image("JP/123", "figure 1.png")

        self.assertEqual(image, b"image-bytes")
        mock_urlopen.assert_called_once_with(
            "http://mona.example/documents/JP%2F123/images/figure%201.png"
        )


if __name__ == "__main__":
    unittest.main()
