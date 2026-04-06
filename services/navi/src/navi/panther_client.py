import json
import os
from dataclasses import dataclass
from typing import Any, TypedDict
from urllib import error, parse, request


class PantherClientError(Exception):
    pass


class PantherJobRequest(TypedDict, total=False):
    id_list: list[str] | None
    chunk_size: int
    max_retries: int
    use_hash_guard: bool


class PantherJobStatus(TypedDict, total=False):
    job_id: str
    status: str
    started_at: str
    updated_at: str
    requested_ids: list[str] | None
    missing_ids: list[str]
    finished_at: str | None
    total: int
    success: int
    failed: int
    progress: float
    source: str | None
    error: str | None


@dataclass(frozen=True)
class PantherConfig:
    base_url: str


def get_panther_config() -> PantherConfig:
    base_url = os.getenv("PANTHER_URL", "http://panther-dev:8000").rstrip("/")
    return PantherConfig(base_url=base_url)


class PantherClient:
    def __init__(self, config: PantherConfig | None = None):
        self.config = config or get_panther_config()

    def get_current_job(self) -> PantherJobStatus:
        data = self._request("GET", "/jobs")
        return self._as_job_status(data)

    def start_job(self, payload: PantherJobRequest) -> PantherJobStatus:
        data = self._request("POST", "/jobs", payload)
        return self._as_job_status(data)

    def list_jobs(self) -> list[str]:
        data = self._request("GET", "/jobs/list")
        if not isinstance(data, list):
            return []
        return [item for item in data if isinstance(item, str)]

    def get_job(self, job_id: str) -> PantherJobStatus:
        safe_job_id = parse.quote(job_id, safe="")
        data = self._request("GET", f"/jobs/{safe_job_id}")
        return self._as_job_status(data)

    def cancel_job(self, job_id: str) -> PantherJobStatus:
        safe_job_id = parse.quote(job_id, safe="")
        data = self._request("GET", f"/jobs/{safe_job_id}/cancel")
        return self._as_job_status(data)

    def _as_job_status(self, data: Any) -> PantherJobStatus:
        return data if isinstance(data, dict) else {}

    def _request(
        self,
        method: str,
        path: str,
        payload: PantherJobRequest | None = None,
    ) -> Any:
        body = None
        headers = {"Accept": "application/json"}
        if payload is not None:
            body = json.dumps(payload).encode("utf-8")
            headers["Content-Type"] = "application/json"

        req = request.Request(
            url=f"{self.config.base_url}{path}",
            data=body,
            headers=headers,
            method=method,
        )

        try:
            with request.urlopen(req, timeout=10) as response:
                raw = response.read()
        except error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            raise PantherClientError(
                f"panther API returned {exc.code} for {method} {path}: {detail}"
            ) from exc
        except error.URLError as exc:
            raise PantherClientError(
                f"panther API request failed for {method} {path}: {exc.reason}"
            ) from exc

        if not raw:
            return None

        try:
            return json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError as exc:
            raise PantherClientError(
                f"panther API returned invalid JSON for {method} {path}"
            ) from exc
