import json

import requests
from craw_api_client import Client
from craw_api_client.api.default import (
    get_job_status_jobs_status_get,
    start_jobs_jobs_post,
)
from craw_api_client.api.default import start_jobs_jobs_post as api_start_job
from craw_api_client.models import (
    JobRequest,
    JobRequestDocCodesItemType0,
    JobRequestDocCodesItemType1,
    JobStateModel,
)
from craw_api_client.types import Response
from fastapi.staticfiles import StaticFiles

client = Client("http://craw-dev:8000")


def start_job(
    overwrite: bool = False,
    doc_codes: list[str] = [],
    max_files: int | None = None,
    doc_id: str | None = None,
):
    ok_codes, ng_codes = check_codes(doc_codes)

    response = api_start_job.sync_detailed(
        client=client,
        body=JobRequest(
            overwrite=overwrite, doc_codes=ok_codes, max_files=max_files, doc_id=doc_id
        ),
    )
    return response.parsed


def check_codes(
    doc_codes: list[str],
) -> tuple[list[JobRequestDocCodesItemType0 | JobRequestDocCodesItemType1], list[str]]:
    ok_codes = []
    ng_codes = []
    for code in doc_codes:
        c = None
        try:
            c = JobRequestDocCodesItemType0(code)
        except ValueError:
            try:
                c = JobRequestDocCodesItemType1(code)
            except ValueError:
                ng_codes.append(code)
        if c:
            ok_codes.append(c)
    return ok_codes, ng_codes


# def get_current_job():
#    jobs.get_current_job()  # type: ignore
#    return {
#        "job_id": "12345678",
#        "status": "running",
#        "started_at": "2024-01-01T12:00:00",
#        "finished_at": None,
#        "current_doc_id": "doc123",
#        "current_file": "file1.txt",
#        "total": 10,
#        "success_files": ["file1.txt", "file2.txt"],
#        "failed_files": ["file3.txt"],
#        "skipped_files": ["file4.txt"],
#        "message": "Crawling in progress...",
#        "cancel_requested": False,
#    }
#    # r = requests.get(f"{CRAW_URL}/job")
#    # if r.status_code == 404:
#    #    return None
#    # return JobStateModel.model_validate(r.json())


def get_job_status() -> JobStateModel | None:
    response = get_job_status_jobs_status_get.sync_detailed(client=client)
    if response and response.status_code == 200:
        return json.loads(response.content)
    else:
        return None


def get_recent_jobs():
    return [
        {
            "job_id": "12345678",
        }
    ]
    # r = requests.get(f"{CRAW_URL}/jobs")
    # return [JobStateModel.model_validate(job) for job in r.json()]
