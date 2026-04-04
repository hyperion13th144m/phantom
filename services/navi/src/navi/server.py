from fastapi import FastAPI

from navi.routers import dashboard, jobs

app = FastAPI(title="Navi Admin")

app.include_router(dashboard.router)
app.include_router(jobs.router)
