import json
from datetime import UTC, datetime
from typing import Any
from urllib import parse

from fastapi import APIRouter, HTTPException, Query, Request
from fastapi.responses import RedirectResponse
from navi.crow_client import CrowClient, CrowClientError, get_crow_config
from navi.ui import templates
from starlette.datastructures import UploadFile

router = APIRouter(prefix="/crow", tags=["crow"])


def _format_error_message(exc: Exception) -> str:
    return str(exc).strip() or exc.__class__.__name__


def _parse_checkbox(value: str | None) -> bool:
    return value in {"on", "true", "1", "yes"}


def _form_value_as_str(value: str | UploadFile | None) -> str | None:
    return value if isinstance(value, str) else None


def _normalize_doc_codes(values: list[str | UploadFile]) -> list[str]:
    seen: set[str] = set()
    normalized: list[str] = []
    for value in values:
        if not isinstance(value, str):
            continue
        code = value.strip()
        if code and code not in seen:
            seen.add(code)
            normalized.append(code)
    return normalized


def _to_datetime_string(timestamp: float | int | None) -> str | None:
    if timestamp is None:
        return None
    return datetime.fromtimestamp(timestamp, tz=UTC).strftime("%Y-%m-%d %H:%M:%S UTC")


def _build_page_context(
    *,
    request: Request,
    flash: str | None = None,
    error_message: str | None = None,
    selected_log_job_id: str | None = None,
) -> dict:
    client = CrowClient()
    status = None
    history: list[str] = []
    available_doc_codes: list[str] = []
    doc_code_categories: list[dict] = []
    selected_log = None
    selected_log_pretty = None

    try:
        status = client.get_status()
    except CrowClientError as exc:
        error_message = error_message or _format_error_message(exc)

    try:
        history = client.list_history()
    except CrowClientError as exc:
        error_message = error_message or _format_error_message(exc)

    try:
        available_doc_codes = client.get_available_doc_codes()
    except CrowClientError as exc:
        error_message = error_message or _format_error_message(exc)

    try:
        doc_code_categories = client.get_doc_code_descriptions()
    except CrowClientError as exc:
        error_message = error_message or _format_error_message(exc)

    if selected_log_job_id:
        try:
            selected_log = client.get_job_log(selected_log_job_id)
            selected_log_pretty = json.dumps(selected_log, ensure_ascii=False, indent=2)
        except CrowClientError as exc:
            error_message = error_message or _format_error_message(exc)

    return {
        "request": request,
        "flash": flash,
        "error_message": error_message,
        "crow_base_url": get_crow_config().base_url,
        "status": status,
        "history": history,
        "available_doc_codes": available_doc_codes,
        "doc_code_categories": doc_code_categories,
        "selected_log_job_id": selected_log_job_id,
        "selected_log": selected_log,
        "selected_log_pretty": selected_log_pretty,
        "format_timestamp": _to_datetime_string,
        "form_doc_id": "",
        "form_max_files": "",
        "form_doc_codes": [],
        "form_overwrite": False,
    }


@router.get("/", name="crow")
def crow_admin(
    request: Request,
    message: str | None = Query(default=None),
    error: str | None = Query(default=None),
    job_id: str | None = Query(default=None),
):
    return templates.TemplateResponse(
        "crow/index.html",
        _build_page_context(
            request=request,
            flash=message,
            error_message=error,
            selected_log_job_id=job_id,
        ),
    )


@router.get("/{job_id}", name="crow_detail")
def crow_admin(
    request: Request,
    job_id: str,
    message: str | None = Query(default=None),
    error: str | None = Query(default=None),
):
    return templates.TemplateResponse(
        "crow/index.html",
        _build_page_context(
            request=request,
            flash=message,
            error_message=error,
            selected_log_job_id=job_id,
        ),
    )


@router.post("/start", name="crow_start")
async def start_crow_job(request: Request):
    form = await request.form()
    selected_doc_codes = _normalize_doc_codes(form.getlist("doc_codes"))
    payload: dict[str, Any] = {
        "overwrite": _parse_checkbox(_form_value_as_str(form.get("overwrite"))),
        "max_files": None,
        "doc_id": None,
        "doc_codes": selected_doc_codes,
    }

    max_files_value = str(form.get("max_files", "")).strip()
    if max_files_value:
        try:
            payload["max_files"] = int(max_files_value)
        except ValueError as exc:
            raise HTTPException(
                status_code=400, detail="max_files must be an integer"
            ) from exc

    doc_id_value = str(form.get("doc_id", "")).strip()
    if doc_id_value:
        payload["doc_id"] = doc_id_value

    client = CrowClient()
    try:
        response = client.start_job(payload)
    except CrowClientError as exc:
        return templates.TemplateResponse(
            "crow/index.html",
            {
                **_build_page_context(
                    request=request,
                    error_message=_format_error_message(exc),
                ),
                "form_doc_id": doc_id_value,
                "form_max_files": max_files_value,
                "form_doc_codes": selected_doc_codes,
                "form_overwrite": payload["overwrite"],
            },
            status_code=502,
        )

    job_id = response.get("job_id", "-")
    status = response.get("status", "-")
    message = response.get("message")
    flash = f"ジョブを開始しました: job_id={job_id}, status={status}"
    if message:
        flash = f"{flash}, message={message}"
    u = request.url_for("crow", message=parse.quote(flash))
    return RedirectResponse(url=u, status_code=303)


@router.post("/cancel", name="crow_cancel")
def cancel_crow_job(request: Request):
    client = CrowClient()
    try:
        response = client.cancel_job()
    except CrowClientError as exc:
        u = request.url_for("crow", error=parse.quote(_format_error_message(exc)))
        return RedirectResponse(
            url=u,
            status_code=303,
        )

    status = response.get("status", "-")
    message = response.get("message")
    flash = f"キャンセルを送信しました: status={status}"
    if message:
        flash = f"{flash}, message={message}"
    u = request.url_for("crow", message=parse.quote(flash))
    return RedirectResponse(url=u, status_code=303)
