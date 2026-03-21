# from fastapi import APIRouter, Form, Request
#
# from navi.api_client import get_job_detail, start_job
# from navi.main import templates
#
# router = APIRouter(prefix="/jobs")
#
#
# @router.get("/new")
# def new_job(request: Request):
#    return templates.TemplateResponse("jobs.html", {"request": request})
#
#
# @router.post("/new")
# def create_job(
#    request: Request,
#    src_dir: str = Form(...),
#    job_name: str = Form(None),
#    force: bool = Form(False),
#    diff: bool = Form(False),
#    max_files: int = Form(None),
#    doc_id: str = Form(None),
# ):
#    payload = {
#        "src_dir": src_dir,
#        "job_name": job_name,
#        "options": {
#            "force": force,
#            "diff": diff,
#            "max_files": max_files,
#            "doc_id": doc_id,
#        },
#    }
#    start_job(payload)
#    return templates.TemplateResponse("job_started.html", {"request": request})
#
