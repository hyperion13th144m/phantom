from __future__ import annotations

import asyncio
import uuid
from dataclasses import dataclass, field
from datetime import UTC, datetime, time, timedelta
from typing import Any, Literal

from navi.crow_client import CrowClient, CrowClientError

ScheduleType = Literal["daily", "interval"]


@dataclass
class CrowSchedule:
    id: str
    schedule_type: ScheduleType
    payload: dict[str, Any]
    created_at: datetime
    updated_at: datetime
    next_run_at: datetime
    daily_time: str | None = None
    interval_minutes: int | None = None
    enabled: bool = True
    last_run_at: datetime | None = None
    last_result: str | None = None
    last_message: str | None = None


class CrowScheduleError(Exception):
    pass


class CrowScheduleManager:
    def __init__(self) -> None:
        self._lock = asyncio.Lock()
        self._schedules: dict[str, CrowSchedule] = {}

    async def list_schedules(self) -> list[CrowSchedule]:
        async with self._lock:
            return sorted(self._schedules.values(), key=lambda s: s.created_at)

    async def create_schedule(
        self,
        *,
        schedule_type: ScheduleType,
        payload: dict[str, Any],
        daily_time: str | None,
        interval_minutes: int | None,
    ) -> CrowSchedule:
        now = datetime.now(UTC)
        schedule_id = str(uuid.uuid4())
        next_run_at = _compute_next_run(
            schedule_type=schedule_type,
            now=now,
            daily_time=daily_time,
            interval_minutes=interval_minutes,
        )
        schedule = CrowSchedule(
            id=schedule_id,
            schedule_type=schedule_type,
            payload=payload,
            created_at=now,
            updated_at=now,
            next_run_at=next_run_at,
            daily_time=daily_time,
            interval_minutes=interval_minutes,
        )
        async with self._lock:
            self._schedules[schedule_id] = schedule
        return schedule

    async def delete_schedule(self, schedule_id: str) -> bool:
        async with self._lock:
            return self._schedules.pop(schedule_id, None) is not None

    async def toggle_schedule(self, schedule_id: str) -> CrowSchedule:
        async with self._lock:
            schedule = self._schedules.get(schedule_id)
            if schedule is None:
                raise CrowScheduleError("指定された予約ジョブは存在しません。")
            schedule.enabled = not schedule.enabled
            schedule.updated_at = datetime.now(UTC)
            if schedule.enabled:
                schedule.next_run_at = _compute_next_run(
                    schedule_type=schedule.schedule_type,
                    now=schedule.updated_at,
                    daily_time=schedule.daily_time,
                    interval_minutes=schedule.interval_minutes,
                )
            return schedule

    async def run_pending(self) -> None:
        now = datetime.now(UTC)
        async with self._lock:
            due_ids = [
                schedule.id
                for schedule in self._schedules.values()
                if schedule.enabled and schedule.next_run_at <= now
            ]

        for schedule_id in due_ids:
            await self._run_schedule(schedule_id)

    async def _run_schedule(self, schedule_id: str) -> None:
        async with self._lock:
            schedule = self._schedules.get(schedule_id)
            if schedule is None or not schedule.enabled:
                return
            payload = dict(schedule.payload)

        client = CrowClient()
        now = datetime.now(UTC)
        try:
            response = client.start_job(payload)
            status = response.get("status", "unknown")
            message = response.get("message") or f"job_id={response.get('job_id', '-') }"
            result = f"ok:{status}"
        except CrowClientError as exc:
            message = str(exc)
            result = "error"

        async with self._lock:
            schedule = self._schedules.get(schedule_id)
            if schedule is None:
                return
            schedule.last_run_at = now
            schedule.last_result = result
            schedule.last_message = message
            schedule.updated_at = now
            schedule.next_run_at = _compute_next_run(
                schedule_type=schedule.schedule_type,
                now=now,
                daily_time=schedule.daily_time,
                interval_minutes=schedule.interval_minutes,
            )


@dataclass
class CrowScheduleRunner:
    manager: CrowScheduleManager
    interval_seconds: int = 15
    _task: asyncio.Task[None] | None = field(default=None, init=False)

    def start(self) -> None:
        if self._task is not None:
            return
        self._task = asyncio.create_task(self._loop())

    async def stop(self) -> None:
        if self._task is None:
            return
        self._task.cancel()
        try:
            await self._task
        except asyncio.CancelledError:
            pass
        self._task = None

    async def _loop(self) -> None:
        while True:
            await self.manager.run_pending()
            await asyncio.sleep(self.interval_seconds)


def _compute_next_run(
    *,
    schedule_type: ScheduleType,
    now: datetime,
    daily_time: str | None,
    interval_minutes: int | None,
) -> datetime:
    if schedule_type == "daily":
        if daily_time is None:
            raise CrowScheduleError("daily schedule には時刻指定が必要です。")
        hour, minute = _parse_daily_time(daily_time)
        candidate = datetime.combine(now.date(), time(hour=hour, minute=minute, tzinfo=UTC))
        if candidate <= now:
            candidate += timedelta(days=1)
        return candidate

    if interval_minutes is None or interval_minutes <= 0:
        raise CrowScheduleError("interval schedule には正の分指定が必要です。")
    return now + timedelta(minutes=interval_minutes)


def _parse_daily_time(value: str) -> tuple[int, int]:
    parts = value.split(":")
    if len(parts) != 2:
        raise CrowScheduleError("毎日実行時刻は HH:MM 形式で指定してください。")
    try:
        hour = int(parts[0])
        minute = int(parts[1])
    except ValueError as exc:
        raise CrowScheduleError("毎日実行時刻は HH:MM 形式で指定してください。") from exc
    if hour < 0 or hour > 23 or minute < 0 or minute > 59:
        raise CrowScheduleError("毎日実行時刻は HH:MM 形式で指定してください。")
    return hour, minute
