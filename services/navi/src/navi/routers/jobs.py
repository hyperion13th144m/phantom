from fastapi import APIRouter, HTTPException, Request

from navi.catalog import get_project, list_job_templates
from navi.ui import templates

router = APIRouter(prefix="/jobs")


@router.get("/{project_key}/new")
def new_job(request: Request, project_key: str):
    project = get_project(project_key)
    if project is None:
        raise HTTPException(status_code=404, detail="Unknown project")

    return templates.TemplateResponse(
        "jobs/new.html",
        {
            "request": request,
            "project": project,
            "templates": list_job_templates(project_key),
        },
    )
