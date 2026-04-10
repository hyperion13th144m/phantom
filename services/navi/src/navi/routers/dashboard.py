from fastapi import APIRouter, Request
from navi.catalog import PROJECTS
from navi.ui import templates

router = APIRouter()


@router.get("/", name="dashboard")
def dashboard(request: Request):
    return templates.TemplateResponse(
        "dashboard.html",
        {
            "request": request,
            "projects": PROJECTS,
        },
    )
