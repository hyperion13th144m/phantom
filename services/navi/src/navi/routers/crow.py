import json
from datetime import UTC, datetime
from zoneinfo import ZoneInfo
from typing import Any
from urllib import parse

from fastapi import APIRouter, HTTPException, Query, Request
from fastapi.responses import JSONResponse, RedirectResponse
from navi.crow_client import CrowClient, CrowClientError, get_crow_config
from navi.crow_scheduler import CrowScheduleError, CrowScheduleManager
from navi.ui import templates
from starlette.datastructures import UploadFile

router = APIRouter(prefix="/crow", tags=["crow"])

JST = ZoneInfo("Asia/Tokyo")


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
    return datetime.fromtimestamp(timestamp, tz=UTC).astimezone(JST).strftime("%Y-%m-%d %H:%M:%S JST")


def _format_datetime(value: datetime | None) -> str:
    if value is None:
        return "-"
    return value.astimezone(UTC).strftime("%Y-%m-%d %H:%M:%S UTC")


def _serialize_status(status: dict[str, Any] | None) -> dict[str, Any] | None:
    if not status:
        return None

    return {
        "job_id": status.get("job_id"),
        "status": status.get("status"),
        "started_at": _to_datetime_string(status.get("started_at")) or "-",
        "finished_at": _to_datetime_string(status.get("finished_at")) or "-",
        "current_doc_id": status.get("current_doc_id") or "-",
        "current_file": status.get("current_file") or "-",
        "total": status.get("total"),
        "success_files": len(status.get("success_files") or []),
        "failed_files": len(status.get("failed_files") or []),
        "skipped_files": len(status.get("skipped_files") or []),
        "cancel_requested": status.get("cancel_requested"),
        "message": status.get("message") or "-",
    }


def _get_schedule_manager(request: Request) -> CrowScheduleManager:
    manager = getattr(request.app.state, "schedule_manager", None)
    if manager is None:
        raise RuntimeError("schedule_manager is not configured")
    return manager


async def _build_page_context(
    *,
    request: Request,
    flash: str | None = None,
    error_message: str | None = None,
    selected_log_job_id: str | None = None,
) -> dict:
    client = CrowClient()
    status = None
    history: list[str] = []
    history_entries: list[dict[str, str | float | None]] = []
    available_doc_codes: list[str] = []
    doc_code_categories: list[dict] = []
    selected_log = None
    selected_log_pretty = None
    schedules = []

    try:
        status = client.get_status()
    except CrowClientError as exc:
        error_message = error_message or _format_error_message(exc)

    try:
        history = client.list_history()
    except CrowClientError as exc:
        error_message = error_message or _format_error_message(exc)

    for job_id in history:
        finished_at_timestamp = None
        finished_at = None
        try:
            job_log = client.get_job_log(job_id)
            finished_at_timestamp = job_log.get("finished_at")
            finished_at = _to_datetime_string(finished_at_timestamp) or "-"
        except CrowClientError as exc:
            error_message = error_message or _format_error_message(exc)
        history_entries.append(
            {
                "job_id": job_id,
                "finished_at": finished_at or "-",
                "finished_at_timestamp": finished_at_timestamp,
            }
        )

    history_entries.sort(
        key=lambda item: float(item.get("finished_at_timestamp") or 0), reverse=True
    )
    history_entries = history_entries[:20]
    history = [str(item["job_id"]) for item in history_entries]

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

    try:
        schedules = await _get_schedule_manager(request).list_schedules()
    except Exception as exc:  # noqa: BLE001
        error_message = error_message or _format_error_message(exc)

    return {
        "request": request,
        "flash": flash,
        "error_message": error_message,
        "crow_base_url": get_crow_config().base_url,
        "status": status,
        "history": history,
        "history_entries": history_entries,
        "available_doc_codes": available_doc_codes,
        "doc_code_categories": doc_code_categories,
        "selected_log_job_id": selected_log_job_id,
        "selected_log": selected_log,
        "selected_log_pretty": selected_log_pretty,
        "format_timestamp": _to_datetime_string,
        "format_datetime": _format_datetime,
        "schedules": schedules,
        "form_doc_id": "",
        "form_max_files": "",
        "form_doc_codes": [],
        "form_overwrite": False,
    }


@router.get("/", name="crow")
async def crow_admin(
    request: Request,
    message: str | None = Query(default=None),
    error: str | None = Query(default=None),
    job_id: str | None = Query(default=None),
):
    return templates.TemplateResponse(
        "crow/index.html",
        await _build_page_context(
            request=request,
            flash=message,
            error_message=error,
            selected_log_job_id=job_id,
        ),
    )


@router.get("/{job_id}", name="crow_detail")
async def crow_admin_detail(
    request: Request,
    job_id: str,
    message: str | None = Query(default=None),
    error: str | None = Query(default=None),
):
    return templates.TemplateResponse(
        "crow/index.html",
        await _build_page_context(
            request=request,
            flash=message,
            error_message=error,
            selected_log_job_id=job_id,
        ),
    )


@router.get("/status/poll", name="crow_status")
async def crow_status():
    client = CrowClient()
    try:
        status = client.get_status()
    except CrowClientError as exc:
        return JSONResponse(
            {"status": None, "error_message": _format_error_message(exc)},
            status_code=502,
        )

    return JSONResponse({"status": _serialize_status(status), "error_message": None})


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
                **await _build_page_context(
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
    u = request.url_for("crow")
    u = f"{u}?message={parse.quote(flash)}"
    return RedirectResponse(url=u, status_code=303)


@router.post("/cancel", name="crow_cancel")
def cancel_crow_job(request: Request):
    client = CrowClient()
    try:
        response = client.cancel_job()
    except CrowClientError as exc:
        u = request.url_for("crow")
        u = f"{u}?error={parse.quote(_format_error_message(exc))}"
        return RedirectResponse(
            url=u,
            status_code=303,
        )

    status = response.get("status", "-")
    message = response.get("message")
    flash = f"キャンセルを送信しました: status={status}"
    if message:
        flash = f"{flash}, message={message}"
    u = request.url_for("crow")
    u = f"{u}?message={parse.quote(flash)}"
    return RedirectResponse(url=u, status_code=303)


@router.post("/schedules", name="crow_schedule_create")
async def create_crow_schedule(request: Request):
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

    schedule_type = str(form.get("schedule_type", "daily")).strip()
    if schedule_type not in {"daily", "interval"}:
        raise HTTPException(status_code=400, detail="invalid schedule_type")

    daily_time = str(form.get("daily_time", "")).strip() or None
    interval_minutes_raw = str(form.get("interval_minutes", "")).strip()
    interval_minutes = None
    if interval_minutes_raw:
        try:
            interval_minutes = int(interval_minutes_raw)
        except ValueError as exc:
            raise HTTPException(
                status_code=400, detail="interval_minutes must be an integer"
            ) from exc

    manager = _get_schedule_manager(request)
    try:
        schedule = await manager.create_schedule(
            schedule_type=schedule_type,
            payload=payload,
            daily_time=daily_time,
            interval_minutes=interval_minutes,
        )
    except CrowScheduleError as exc:
        u = request.url_for("crow")
        u = f"{u}?error={parse.quote(_format_error_message(exc))}"
        return RedirectResponse(url=u, status_code=303)

    flash = f"予約ジョブを作成しました: schedule_id={schedule.id}, next_run={_format_datetime(schedule.next_run_at)}"
    u = request.url_for("crow")
    u = f"{u}?message={parse.quote(flash)}"
    return RedirectResponse(url=u, status_code=303)


@router.post("/schedules/{schedule_id}/delete", name="crow_schedule_delete")
async def delete_crow_schedule(request: Request, schedule_id: str):
    deleted = await _get_schedule_manager(request).delete_schedule(schedule_id)
    if not deleted:
        u = request.url_for("crow")
        u = f"{u}?error={parse.quote('指定された予約ジョブは存在しません。')}"
        return RedirectResponse(url=u, status_code=303)
    u = request.url_for("crow")
    u = f"{u}?message={parse.quote(f'予約ジョブを削除しました: {schedule_id}')}"
    return RedirectResponse(url=u, status_code=303)


@router.post("/schedules/{schedule_id}/toggle", name="crow_schedule_toggle")
async def toggle_crow_schedule(request: Request, schedule_id: str):
    manager = _get_schedule_manager(request)
    try:
        schedule = await manager.toggle_schedule(schedule_id)
    except CrowScheduleError as exc:
        u = request.url_for("crow")
        u = f"{u}?error={parse.quote(_format_error_message(exc))}"
        return RedirectResponse(url=u, status_code=303)

    state = "有効化" if schedule.enabled else "無効化"
    u = request.url_for("crow")
    u = f"{u}?message={parse.quote(f'予約ジョブを{state}しました: {schedule_id}')}"
    return RedirectResponse(url=u, status_code=303)
