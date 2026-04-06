import asyncio
import importlib
import logging
import os
import tempfile
import unittest
from unittest.mock import patch

_PREVIOUS_LOGGING_DISABLE = logging.root.manager.disable


def setUpModule() -> None:
    logging.disable(logging.CRITICAL)


def tearDownModule() -> None:
    logging.disable(_PREVIOUS_LOGGING_DISABLE)


class _FakeJobManager:
    def __init__(self, server_module):
        self._server = server_module

    def start_job(self, request):
        return self._server.JobStatus(
            job_id="job-123",
            status="running",
            started_at="2026-04-06T12:00:00+00:00",
            updated_at="2026-04-06T12:00:00+00:00",
            requested_ids=request.id_list,
            missing_ids=["JP-9"],
            total=2,
            success=0,
            failed=0,
            progress=0.0,
            source="local",
        )

    def get_job(self, job_id):
        return self._server.JobStatus(
            job_id=job_id,
            status="completed",
            started_at="2026-04-06T12:00:00+00:00",
            updated_at="2026-04-06T12:01:00+00:00",
            requested_ids=["JP-1", "JP-2", "JP-9"],
            missing_ids=["JP-9"],
            finished_at="2026-04-06T12:01:00+00:00",
            total=2,
            success=2,
            failed=0,
            progress=1.0,
            source="local",
        )

    def get_current(self):
        return {
            "running": self.get_job("job-123").model_copy(
                update={
                    "status": "running",
                    "finished_at": None,
                    "updated_at": "2026-04-06T12:00:30+00:00",
                    "progress": 0.5,
                    "success": 1,
                }
            ),
            "latest": self.get_job("job-123"),
            "count": 1,
        }

    def list_jobs(self):
        return ["job-123"]

    def cancel(self, job_id):
        return self.get_job(job_id).model_copy(
            update={
                "status": "cancelled",
                "updated_at": "2026-04-06T12:00:45+00:00",
                "finished_at": "2026-04-06T12:00:45+00:00",
            }
        )


class ServerApiTests(unittest.TestCase):
    def _load_server_module(self, data_root: str):
        with patch.dict(
            os.environ,
            {
                "DATA_ROOT": data_root,
                "ES_URL": "http://localhost:9200",
                "LOG_DIR": data_root,
                "LOG_LEVEL": "CRITICAL",
                "MONA_URL": "",
            },
            clear=False,
        ):
            import panther.server

            return importlib.reload(panther.server)

    def test_start_job_route_returns_updated_at_requested_ids_and_missing_ids(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            server_module = self._load_server_module(tmpdir)
            server_module.job_manager = _FakeJobManager(server_module)

            result = asyncio.run(
                server_module.start_job(
                    server_module.JobRequest(id_list=["JP-1", "JP-2", "JP-9"], chunk_size=10)
                )
            )

        body = result.model_dump()
        self.assertEqual(body["job_id"], "job-123")
        self.assertEqual(body["status"], "running")
        self.assertEqual(body["updated_at"], "2026-04-06T12:00:00+00:00")
        self.assertEqual(body["requested_ids"], ["JP-1", "JP-2", "JP-9"])
        self.assertEqual(body["missing_ids"], ["JP-9"])
        self.assertEqual(body["progress"], 0.0)

    def test_get_job_route_returns_updated_at_requested_ids_and_missing_ids(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            server_module = self._load_server_module(tmpdir)
            server_module.job_manager = _FakeJobManager(server_module)

            result = asyncio.run(server_module.get_job("job-123"))

        body = result.model_dump()
        self.assertEqual(body["job_id"], "job-123")
        self.assertEqual(body["updated_at"], "2026-04-06T12:01:00+00:00")
        self.assertEqual(body["requested_ids"], ["JP-1", "JP-2", "JP-9"])
        self.assertEqual(body["missing_ids"], ["JP-9"])
        self.assertEqual(body["finished_at"], "2026-04-06T12:01:00+00:00")
        self.assertEqual(body["progress"], 1.0)

    def test_get_current_route_returns_nested_job_status_fields(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            server_module = self._load_server_module(tmpdir)
            server_module.job_manager = _FakeJobManager(server_module)

            result = asyncio.run(server_module.get_current_job())

        self.assertEqual(result["count"], 1)
        self.assertEqual(result["running"].model_dump()["updated_at"], "2026-04-06T12:00:30+00:00")
        self.assertEqual(result["running"].model_dump()["requested_ids"], ["JP-1", "JP-2", "JP-9"])
        self.assertEqual(result["running"].model_dump()["missing_ids"], ["JP-9"])
        self.assertEqual(result["latest"].model_dump()["updated_at"], "2026-04-06T12:01:00+00:00")
        self.assertEqual(result["latest"].model_dump()["requested_ids"], ["JP-1", "JP-2", "JP-9"])

    def test_get_job_list_route_returns_job_ids(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            server_module = self._load_server_module(tmpdir)
            server_module.job_manager = _FakeJobManager(server_module)

            result = asyncio.run(server_module.get_job_list())

        self.assertEqual(result, ["job-123"])

    def test_cancel_job_route_returns_cancelled_status(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            server_module = self._load_server_module(tmpdir)
            server_module.job_manager = _FakeJobManager(server_module)

            result = asyncio.run(server_module.cancel_job("job-123"))

        body = result.model_dump()
        self.assertEqual(body["status"], "cancelled")
        self.assertEqual(body["updated_at"], "2026-04-06T12:00:45+00:00")
        self.assertEqual(body["missing_ids"], ["JP-9"])


if __name__ == "__main__":
    unittest.main()
