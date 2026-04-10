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

