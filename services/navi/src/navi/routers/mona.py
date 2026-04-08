import json
from typing import Any
from urllib import parse

from fastapi import APIRouter, Query, Request
from fastapi.responses import RedirectResponse
from navi.mona_client import MonaClient, MonaClientError, get_mona_config
from navi.ui import templates

router = APIRouter(prefix="/mona", tags=["mona"])


def _format_error_message(exc: Exception) -> str:
    return str(exc).strip() or exc.__class__.__name__


def _build_page_context(
    *,
    request: Request,
    flash: str | None = None,
    error_message: str | None = None,
) -> dict[str, Any]:
    client = MonaClient()
    status = None
    status_pretty = None

    try:
        status = client.get_documents_status()
        status_pretty = json.dumps(status, ensure_ascii=False, indent=2)
    except MonaClientError as exc:
        error_message = error_message or _format_error_message(exc)

    return {
        "request": request,
        "flash": flash,
        "error_message": error_message,
        "mona_base_url": get_mona_config().base_url,
        "status": status,
        "status_pretty": status_pretty,
    }


@router.get("/", name="mona")
def mona_admin(
    request: Request,
    message: str | None = Query(default=None),
    error: str | None = Query(default=None),
):
    return templates.TemplateResponse(
        "mona/index.html",
        _build_page_context(
            request=request,
            flash=message,
            error_message=error,
        ),
    )


@router.post("/reload", name="mona_reload")
def reload_mona_documents(request: Request):
    client = MonaClient()
    try:
        response = client.reload_documents()
    except MonaClientError as exc:
        u = request.url_for("mona", error=parse.quote(_format_error_message(exc)))
        return RedirectResponse(
            url=u,
            status_code=303,
        )

    flash = "documents reload を実行しました"
    if response:
        flash = f"{flash}: {json.dumps(response, ensure_ascii=False)}"
    u = request.url_for("mona", message=parse.quote(flash))
    return RedirectResponse(url=u, status_code=303)
