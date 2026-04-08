import json
from typing import Any
from urllib import parse

from fastapi import APIRouter, HTTPException, Query, Request
from fastapi.responses import RedirectResponse
from navi.panther_client import (
    PantherClient,
    PantherClientError,
    PantherJobRequest,
    get_panther_config,
)
from navi.ui import templates

router = APIRouter(prefix="/panther", tags=["panther"])


def _format_error_message(exc: Exception) -> str:
    return str(exc).strip() or exc.__class__.__name__


def _parse_checkbox(value: str | None) -> bool:
    return value in {"on", "true", "1", "yes"}


def _parse_id_list(raw: str) -> list[str] | None:
    if not raw.strip():
        return None

    normalized = raw.replace("\r", "\n").replace(",", "\n")
    ids: list[str] = []
    seen: set[str] = set()
    for token in normalized.split("\n"):
        value = token.strip()
        if value and value not in seen:
            seen.add(value)
            ids.append(value)
    return ids or None


def _build_page_context(
    *,
    request: Request,
    flash: str | None = None,
    error_message: str | None = None,
    selected_job_id: str | None = None,
) -> dict[str, Any]:
    client = PantherClient()

    current_job = None
    job_list: list[str] = []
    selected_job = None
    selected_job_pretty = None

    try:
        current_job = client.get_current_job()
    except PantherClientError as exc:
        error_message = error_message or _format_error_message(exc)

    try:
        job_list = client.list_jobs()
    except PantherClientError as exc:
        error_message = error_message or _format_error_message(exc)

    if selected_job_id:
        try:
            selected_job = client.get_job(selected_job_id)
            selected_job_pretty = json.dumps(selected_job, ensure_ascii=False, indent=2)
        except PantherClientError as exc:
            error_message = error_message or _format_error_message(exc)

    return {
        "request": request,
        "flash": flash,
        "error_message": error_message,
        "panther_base_url": get_panther_config().base_url,
        "current_job": current_job,
        "job_list": job_list,
        "selected_job_id": selected_job_id,
        "selected_job": selected_job,
        "selected_job_pretty": selected_job_pretty,
        "form_id_list": "",
        "form_chunk_size": "500",
        "form_max_retries": "5",
        "form_use_hash_guard": False,
    }


@router.get("/", name="panther")
def panther_admin(
    request: Request,
    message: str | None = Query(default=None),
    error: str | None = Query(default=None),
    job_id: str | None = Query(default=None),
):
    return templates.TemplateResponse(
        "panther/index.html",
        _build_page_context(
            request=request,
            flash=message,
            error_message=error,
            selected_job_id=job_id,
        ),
    )


@router.post("/start", name="panther_start")
async def start_panther_job(request: Request):
    form = await request.form()

    id_list_raw = str(form.get("id_list", "")).strip()
    chunk_size_raw = str(form.get("chunk_size", "500")).strip()
    max_retries_raw = str(form.get("max_retries", "5")).strip()
    use_hash_guard = _parse_checkbox(str(form.get("use_hash_guard", "")))

    try:
        chunk_size = int(chunk_size_raw)
    except ValueError as exc:
        raise HTTPException(
            status_code=400, detail="chunk_size must be an integer"
        ) from exc

    try:
        max_retries = int(max_retries_raw)
    except ValueError as exc:
        raise HTTPException(
            status_code=400, detail="max_retries must be an integer"
        ) from exc

    payload: PantherJobRequest = {
        "id_list": _parse_id_list(id_list_raw),
        "chunk_size": chunk_size,
        "max_retries": max_retries,
        "use_hash_guard": use_hash_guard,
    }

    client = PantherClient()
    try:
        response = client.start_job(payload)
    except PantherClientError as exc:
        return templates.TemplateResponse(
            "panther/index.html",
            {
                **_build_page_context(
                    request=request,
                    error_message=_format_error_message(exc),
                ),
                "form_id_list": id_list_raw,
                "form_chunk_size": chunk_size_raw,
                "form_max_retries": max_retries_raw,
                "form_use_hash_guard": use_hash_guard,
            },
            status_code=502,
        )

    job_id = response.get("job_id", "-")
    status = response.get("status", "-")
    message = response.get("message")
    flash = f"ジョブを開始しました: job_id={job_id}, status={status}"
    if message:
        flash = f"{flash}, message={message}"

    return RedirectResponse(
        url=f"/panther?message={parse.quote(flash)}", status_code=303
    )


@router.post("/cancel", name="panther_cancel")
async def cancel_panther_job(request: Request):
    form = await request.form()
    job_id = str(form.get("job_id", "")).strip()
    if not job_id:
        return RedirectResponse(
            url=f"/panther?error={parse.quote('job_id を指定してください')}",
            status_code=303,
        )

    client = PantherClient()
    try:
        response = client.cancel_job(job_id)
    except PantherClientError as exc:
        return RedirectResponse(
            url=f"/panther?error={parse.quote(_format_error_message(exc))}",
            status_code=303,
        )

    status = response.get("status", "-")
    message = response.get("message")
    flash = f"ジョブキャンセルを送信しました: job_id={job_id}, status={status}"
    if message:
        flash = f"{flash}, message={message}"

    return RedirectResponse(
        url=f"/panther?message={parse.quote(flash)}&job_id={parse.quote(job_id)}",
        status_code=303,
    )
