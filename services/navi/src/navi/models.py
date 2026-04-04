from dataclasses import dataclass
from enum import Enum


class JobType(str, Enum):
    CRAWL = "crawl"
    UPLOAD = "upload"


@dataclass(frozen=True)
class ManagedProject:
    key: str
    name: str
    description: str
    available_jobs: tuple[JobType, ...]


@dataclass(frozen=True)
class JobTemplate:
    project_key: str
    job_type: JobType
    service_name: str
    endpoint: str
    summary: str
