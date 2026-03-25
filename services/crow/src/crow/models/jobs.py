from datetime import datetime
from typing import Any, List, Literal, Optional, Union, get_args
from uuid import uuid4

from pydantic import BaseModel, Field

from crow.crawler.config import Category, DocCode

Status = Literal["idle", "queued", "running", "completed", "failed", "canceled"]


class JobRequest(BaseModel):
    overwrite: bool = Field(
        default=False,
        description="force to crawl when existing JSON/webp files are present",
    )
    max_files: Optional[int] = Field(
        default=None, ge=0, description="maximum number of files to process"
    )
    doc_id: Optional[str] = Field(
        default=None, description="crawl only the specified docId"
    )
    doc_codes: List[Union[Category, DocCode]] = Field(
        default_factory=list, description="crawl only the specified docCodes"
    )

    def get_doc_codes(self) -> List[str]:
        return [str(code) for code in self.doc_codes]


class JobResponse(BaseModel):
    job_id: str
    status: str
    message: Optional[str] = None


class JobStateModel(BaseModel):
    job_id: str
    status: Status
    started_at: Optional[float] = None
    finished_at: Optional[float] = None

    current_doc_id: Optional[str] = None
    current_file: Optional[str] = None

    total: int = 0
    success_files: List[str]
    failed_files: List[str]
    skipped_files: List[str]

    message: str = ""
    cancel_requested: bool

    request: JobRequest


class JobState:
    def __init__(self, job_request: JobRequest):
        self.job_id = uuid4().hex[:8]
        self.status: Status = "idle"
        self.started_at: datetime | None = None
        self.finished_at: datetime | None = None

        self.current_doc_id: Optional[str] = None
        self.current_file: Optional[str] = None

        self.total = 0
        self.success_files = []
        self.failed_files = []
        self.skipped_files = []

        self.message = ""
        self.cancel_requested = False

        self.request = job_request

    def run(self):
        self.status = "running"
        self.started_at = datetime.now()

    def progress(
        self,
        doc_id: Optional[str],
        archive_path: str,
        status: Literal["success", "fail", "skip"],
        message: Optional[str] = None,
    ):
        self.current_doc_id = doc_id
        self.current_file = archive_path
        if status == "success":
            self.success_files.append(archive_path)
        elif status == "fail":
            self.failed_files.append(archive_path)
        elif status == "skip":
            self.skipped_files.append(archive_path)
        if message:
            self.message = message
        self.total += 1

    def cancel(self):
        self.status = "canceled"
        self.finished_at = datetime.now()

    def complete(self):
        self.status = "completed"
        self.finished_at = datetime.now()

    def fail(self, message: str):
        self.status = "failed"
        self.finished_at = datetime.now()
        self.message = message

    def request_cancel(self):
        self.cancel_requested = True

    def to_model(self) -> JobStateModel:
        return JobStateModel(
            job_id=self.job_id,
            status=self.status,
            started_at=self.started_at.timestamp() if self.started_at else None,
            finished_at=self.finished_at.timestamp() if self.finished_at else None,
            current_doc_id=self.current_doc_id,
            current_file=self.current_file,
            total=self.total,
            success_files=self.success_files,
            failed_files=self.failed_files,
            skipped_files=self.skipped_files,
            message=self.message,
            cancel_requested=self.cancel_requested,
            request=self.request,
        )
