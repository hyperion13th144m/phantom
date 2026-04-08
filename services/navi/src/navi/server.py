from contextlib import asynccontextmanager

from fastapi import FastAPI

from navi.crow_scheduler import CrowScheduleManager, CrowScheduleRunner
from navi.routers import crow, dashboard, mona, orchestration, panther

schedule_manager = CrowScheduleManager()
schedule_runner = CrowScheduleRunner(manager=schedule_manager)


@asynccontextmanager
async def lifespan(_: FastAPI):
    schedule_runner.start()
    try:
        yield
    finally:
        await schedule_runner.stop()


app = FastAPI(title="Navi Admin", root_path="/navi", lifespan=lifespan)

app.state.schedule_manager = schedule_manager

app.include_router(dashboard.router)
app.include_router(crow.router)
app.include_router(panther.router)
app.include_router(mona.router)
app.include_router(orchestration.router)
