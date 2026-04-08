from fastapi import FastAPI

from navi.routers import crow, dashboard, mona, orchestration, panther

app = FastAPI(title="Navi Admin", root_path="/navi")

app.include_router(dashboard.router)
app.include_router(crow.router)
app.include_router(panther.router)
app.include_router(mona.router)
app.include_router(orchestration.router)
