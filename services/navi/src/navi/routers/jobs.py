from typing import List

from crow_api_client.api.default.start_jobs_jobs_post import sync_detailed
from crow_api_client.models import (
    JobRequest,
    JobRequestDocCodesItemType0,
    JobRequestDocCodesItemType1,
)
from fastapi import APIRouter, Form, Request

from navi.api_client import start_job
from navi.ui import templates

router = APIRouter(prefix="/jobs")


@router.get("/start")
def new_job(request: Request):
    return templates.TemplateResponse("jobs/get-start.html", {"request": request})


@router.post("/start")
def create_job(
    request: Request,
    overwrite: bool = Form(False),
    doc_codes: list[str] = Form([]),
    max_files: int = Form(None),
    doc_id: str = Form(None),
):
    response = start_job(
        overwrite=overwrite, doc_codes=doc_codes, max_files=max_files, doc_id=doc_id
    )
    return templates.TemplateResponse(
        "jobs/post-start.html", {"request": request, "job_request": response}
    )
