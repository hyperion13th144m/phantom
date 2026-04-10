from navi.models import JobType, ManagedProject

PROJECTS: tuple[ManagedProject, ...] = (
    ManagedProject(
        key="crow",
        name="Crow",
        description="特許文書を収集するサービス。",
        available_jobs=(JobType.CRAWL,),
    ),
    ManagedProject(
        key="panther",
        name="Panther",
        description="収集した特許文書をデータベースに登録するサービス。",
        available_jobs=(JobType.UPLOAD,),
    ),
    ManagedProject(
        key="mona",
        name="Mona",
        description="登録されている特許文書のステータス確認と再読み込みを行うサービス。",
        available_jobs=(),
    ),
)

def get_project(project_key: str) -> ManagedProject | None:
    return next((project for project in PROJECTS if project.key == project_key), None)


