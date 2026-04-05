import json
import os
from dataclasses import dataclass
from typing import Any
from urllib import error, parse, request


class CrowClientError(Exception):
    pass


@dataclass(frozen=True)
class CrowConfig:
    base_url: str


def get_crow_config() -> CrowConfig:
    base_url = os.getenv("CROW_BASE_URL", "http://crow-dev:8000").rstrip("/")
    return CrowConfig(base_url=base_url)


class CrowClient:
    def __init__(self, config: CrowConfig | None = None):
        self.config = config or get_crow_config()

    def list_history(self) -> list[str]:
        data = self._request("GET", "/jobs/history")
        return data if isinstance(data, list) else []

    def get_status(self) -> dict[str, Any]:
        data = self._request("GET", "/jobs/status")
        return data if isinstance(data, dict) else {}

    def get_available_doc_codes(self) -> list[str]:
        data = self._request("GET", "/jobs/available-codes")
        return data if isinstance(data, list) else []

    def get_doc_code_descriptions(self) -> list[dict[str, Any]]:
        data = self._request("GET", "/jobs/codes-description")
        return data if isinstance(data, list) else []

    def get_job_log(self, job_id: str) -> dict[str, Any]:
        safe_job_id = parse.quote(job_id, safe="")
        data = self._request("GET", f"/jobs/{safe_job_id}/log")
        return data if isinstance(data, dict) else {}

    def start_job(self, payload: dict[str, Any]) -> dict[str, Any]:
        data = self._request("POST", "/jobs", payload)
        return data if isinstance(data, dict) else {}

    def cancel_job(self) -> dict[str, Any]:
        data = self._request("POST", "/jobs/cancel")
        return data if isinstance(data, dict) else {}

    def _request(
        self,
        method: str,
        path: str,
        payload: dict[str, Any] | None = None,
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
            raise CrowClientError(
                f"crow API returned {exc.code} for {method} {path}: {detail}"
            ) from exc
        except error.URLError as exc:
            raise CrowClientError(
                f"crow API request failed for {method} {path}: {exc.reason}"
            ) from exc

        if not raw:
            return None

        try:
            return json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError as exc:
            raise CrowClientError(
                f"crow API returned invalid JSON for {method} {path}"
            ) from exc
