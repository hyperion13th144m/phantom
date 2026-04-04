from fastapi import APIRouter, Request

from navi.catalog import PROJECTS, list_job_templates
from navi.ui import templates

router = APIRouter()


@router.get("/")
def dashboard(request: Request):
    return templates.TemplateResponse(
        "dashboard.html",
        {
            "request": request,
            "projects": PROJECTS,
            "job_templates": list_job_templates(),
        },
    )
