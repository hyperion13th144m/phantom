import requests

from navi.models.job_state import JobStateModel

CRAW_URL = "http://craw-dev:8000"


def start_job(payload):
    r = requests.post(f"{CRAW_URL}/jobs", json=payload)
    r.raise_for_status()
    return r.json()


def get_current_job():
    return {
        "job_id": "12345678",
        "status": "running",
        "started_at": "2024-01-01T12:00:00",
        "finished_at": None,
        "current_doc_id": "doc123",
        "current_file": "file1.txt",
        "total": 10,
        "success_files": ["file1.txt", "file2.txt"],
        "failed_files": ["file3.txt"],
        "skipped_files": ["file4.txt"],
        "message": "Crawling in progress...",
        "cancel_requested": False,
    }
    # r = requests.get(f"{CRAW_URL}/job")
    # if r.status_code == 404:
    #    return None
    # return JobStateModel.model_validate(r.json())


def get_current_job_status():
    r = requests.get(f"{CRAW_URL}/jobs/status")
    if r.status_code == 404:
        return None
    return r.json().get("status")


def get_recent_jobs():
    return [
        {
            "job_id": "12345678",
        }
    ]
    # r = requests.get(f"{CRAW_URL}/jobs")
    # return [JobStateModel.model_validate(job) for job in r.json()]
