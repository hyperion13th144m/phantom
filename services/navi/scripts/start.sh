#!/bin/bash

exec uv run uvicorn navi.server:app --host 0.0.0.0 --port 8000 --reload
