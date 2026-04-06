import logging
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

from panther.cli import collect_requested_ids, load_id_list_file, main
from panther.upload_documents import UploadResult, format_upload_result_summary

_PREVIOUS_LOGGING_DISABLE = logging.root.manager.disable


def setUpModule() -> None:
    logging.disable(logging.CRITICAL)


def tearDownModule() -> None:
    logging.disable(_PREVIOUS_LOGGING_DISABLE)


class CliHelpersTests(unittest.TestCase):
    def test_load_id_list_file_skips_comments_and_blank_lines(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            path = Path(tmpdir) / "ids.txt"
            path.write_text("\n# comment\nJP-1\n  JP-2  \n\n", encoding="utf-8")

            self.assertEqual(load_id_list_file(str(path)), ["JP-1", "JP-2"])

    def test_collect_requested_ids_merges_and_deduplicates_sources(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            path = Path(tmpdir) / "ids.txt"
            path.write_text("JP-2\nJP-3\n", encoding="utf-8")

            self.assertEqual(
                collect_requested_ids(["JP-1", "JP-2", "JP-1"], str(path)),
                ["JP-1", "JP-2", "JP-3"],
            )

    def test_format_upload_result_summary_returns_stable_summary(self):
        result = UploadResult(
            source="local",
            total=3,
            success=2,
            failed=1,
            requested_ids=["JP-1"],
            missing_ids=["JP-9"],
        )

        self.assertEqual(
            format_upload_result_summary(result),
            "Upload completed: source=local total=3 success=2 failed=1 progress=1.00",
        )


class CliMainTests(unittest.TestCase):
    @patch("panther.cli.execute_upload")
    @patch("panther.cli.create_es_client")
    @patch("panther.cli.create_document_source")
    @patch("panther.cli.setup_logging")
    def test_main_passes_requested_ids_to_execute_upload(
        self,
        setup_logging,
        create_document_source,
        create_es_client,
        execute_upload,
    ):
        create_document_source.return_value = MagicMock(source="local")
        create_es_client.return_value = MagicMock()
        execute_upload.return_value = UploadResult(
            source="local",
            total=1,
            success=1,
            failed=0,
            requested_ids=["JP-1", "JP-2"],
            missing_ids=["JP-9"],
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            id_file = Path(tmpdir) / "ids.txt"
            id_file.write_text("JP-2\nJP-9\n", encoding="utf-8")
            with patch(
                "sys.argv",
                [
                    "panther",
                    "--data-root",
                    tmpdir,
                    "--id",
                    "JP-1",
                    "--id-list-file",
                    str(id_file),
                ],
            ):
                exit_code = main()

        self.assertEqual(exit_code, 0)
        execute_upload.assert_called_once()
        self.assertEqual(
            execute_upload.call_args.kwargs["id_list"],
            ["JP-1", "JP-2", "JP-9"],
        )

    @patch("panther.cli.setup_logging")
    def test_main_returns_error_when_id_list_file_is_missing(self, setup_logging):
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch(
                "sys.argv",
                [
                    "panther",
                    "--data-root",
                    tmpdir,
                    "--id-list-file",
                    str(Path(tmpdir) / "missing.txt"),
                ],
            ):
                exit_code = main()

        self.assertEqual(exit_code, 1)


if __name__ == "__main__":
    unittest.main()
