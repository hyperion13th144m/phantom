import hashlib
import hmac
import json
import logging
import os
from dataclasses import dataclass
from datetime import UTC
from urllib import error, request

from crow.models.jobs import JobState


@dataclass(frozen=True)
class OrchestrationWebhookConfig:
    url: str
    secret: str
    timeout_seconds: float


class OrchestrationWebhookNotifier:
    def __init__(self, config: OrchestrationWebhookConfig | None = None):
        self._config = config or self._config_from_env()
        self._logger = logging.getLogger("crow.orchestration")

    @staticmethod
    def _config_from_env() -> OrchestrationWebhookConfig | None:
        url = os.getenv("NAVI_ORCHESTRATION_WEBHOOK_URL", "").strip()
        if not url:
            return None

        timeout_raw = os.getenv("NAVI_ORCHESTRATION_WEBHOOK_TIMEOUT_SECONDS", "5").strip()
        try:
            timeout_seconds = float(timeout_raw)
        except ValueError:
            timeout_seconds = 5.0

        timeout_seconds = max(1.0, timeout_seconds)
        secret = os.getenv("NAVI_ORCHESTRATION_WEBHOOK_SECRET", "")
        return OrchestrationWebhookConfig(
            url=url,
            secret=secret,
            timeout_seconds=timeout_seconds,
        )

    def notify_crow_job_finished(self, job: JobState) -> None:
        if self._config is None:
            return

        payload = {
            "crow_job_id": job.job_id,
            "status": job.status,
            "finished_at": job.finished_at.astimezone(UTC).isoformat() if job.finished_at else None,
        }
        body = json.dumps(payload).encode("utf-8")

        headers = {
            "Accept": "application/json",
            "Content-Type": "application/json",
        }
        if self._config.secret:
            digest = hmac.new(
                self._config.secret.encode("utf-8"),
                body,
                hashlib.sha256,
            ).hexdigest()
            headers["X-Webhook-Signature"] = f"sha256={digest}"

        req = request.Request(
            url=self._config.url,
            data=body,
            headers=headers,
            method="POST",
        )

        try:
            with request.urlopen(req, timeout=self._config.timeout_seconds):
                return
        except error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            self._logger.warning(
                "Failed to notify orchestration webhook (HTTP %s): %s",
                exc.code,
                detail,
            )
        except error.URLError as exc:
            self._logger.warning(
                "Failed to notify orchestration webhook (network error): %s",
                exc.reason,
            )
        except Exception as exc:
            self._logger.warning("Failed to notify orchestration webhook: %s", exc)
