from fastapi import APIRouter, Request

from navi.api_client import get_job_status
from navi.ui import templates

router = APIRouter()


@router.get("/")
def dashboard(request: Request):
    # current = get_current_job()
    # recent = get_recent_jobs()
    status = get_job_status()
    return templates.TemplateResponse(
        "dashboard.html", {"request": request, "status": status}
    )
