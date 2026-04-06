from fastapi import FastAPI

from navi.routers import crow, dashboard, mona, panther

app = FastAPI(title="Navi Admin")

app.include_router(dashboard.router)
app.include_router(crow.router)
app.include_router(panther.router)
app.include_router(mona.router)
