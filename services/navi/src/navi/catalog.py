from navi.models import JobTemplate, JobType, ManagedProject

PROJECTS: tuple[ManagedProject, ...] = (
    ManagedProject(
        key="crow",
        name="Crow",
        description="文書クローリングを実行するサービス。",
        available_jobs=(JobType.CRAWL,),
    ),
    ManagedProject(
        key="panther",
        name="Panther",
        description="アップロード処理を実行するサービス。",
        available_jobs=(JobType.UPLOAD,),
    ),
    ManagedProject(
        key="mona",
        name="Mona",
        description="documents status の確認と reload を行うサービス。",
        available_jobs=(),
    ),
)

JOB_TEMPLATES: tuple[JobTemplate, ...] = (
    JobTemplate(
        project_key="crow",
        job_type=JobType.CRAWL,
        service_name="crow",
        endpoint="POST /jobs",
        summary="クローリングジョブを開始する。",
    ),
    JobTemplate(
        project_key="panther",
        job_type=JobType.UPLOAD,
        service_name="panther",
        endpoint="POST /jobs/start",
        summary="アップロードジョブを開始する。",
    ),
)


def get_project(project_key: str) -> ManagedProject | None:
    return next((project for project in PROJECTS if project.key == project_key), None)


def list_job_templates(project_key: str | None = None) -> list[JobTemplate]:
    if project_key is None:
        return list(JOB_TEMPLATES)
    return [template for template in JOB_TEMPLATES if template.project_key == project_key]
