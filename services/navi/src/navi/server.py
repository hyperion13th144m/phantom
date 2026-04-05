from fastapi import FastAPI

from navi.routers import crow, dashboard

app = FastAPI(title="Navi Admin")

app.include_router(dashboard.router)
app.include_router(crow.router)
