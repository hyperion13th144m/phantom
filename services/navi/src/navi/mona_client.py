import json
import os
from dataclasses import dataclass
from typing import Any
from urllib import error, request


class MonaClientError(Exception):
    pass


@dataclass(frozen=True)
class MonaConfig:
    base_url: str


def get_mona_config() -> MonaConfig:
    base_url = os.getenv("MONA_URL", "http://mona-dev:8000").rstrip("/")
    return MonaConfig(base_url=base_url)


class MonaClient:
    def __init__(self, config: MonaConfig | None = None):
        self.config = config or get_mona_config()

    def get_documents_status(self) -> dict[str, Any]:
        data = self._request("GET", "/documents/status")
        return data if isinstance(data, dict) else {"value": data}

    def reload_documents(self) -> dict[str, Any]:
        data = self._request("POST", "/documents/reloads")
        return data if isinstance(data, dict) else {"value": data}

    def _request(self, method: str, path: str) -> Any:
        req = request.Request(
            url=f"{self.config.base_url}{path}",
            headers={"Accept": "application/json"},
            method=method,
        )

        try:
            with request.urlopen(req, timeout=10) as response:
                raw = response.read()
        except error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            raise MonaClientError(
                f"mona API returned {exc.code} for {method} {path}: {detail}"
            ) from exc
        except error.URLError as exc:
            raise MonaClientError(
                f"mona API request failed for {method} {path}: {exc.reason}"
            ) from exc

        if not raw:
            return {}

        try:
            return json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError as exc:
            raise MonaClientError(
                f"mona API returned invalid JSON for {method} {path}"
            ) from exc
