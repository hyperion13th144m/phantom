from pathlib import Path

from fastapi import FastAPI

from navi.routers import dashboard, jobs

app = FastAPI()

# BASE_DIR = Path(__file__).resolve().parent
# app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")

app.include_router(dashboard.router)
app.include_router(jobs.router)
