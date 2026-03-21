from fastapi import APIRouter, Request

from navi.api_client import get_current_job, get_current_job_status, get_recent_jobs
from navi.ui import templates

router = APIRouter()


@router.get("/")
def dashboard(request: Request):
    current = get_current_job()
    recent = get_recent_jobs()
    status = get_current_job_status()
    return templates.TemplateResponse(
        "dashboard.html", {"request": request, "result": "hoge", "status": status}
    )
    # return templates.TemplateResponse(
    #    "dashboard.html", {"request": request, "current": current, "recent": recent}
    # )
