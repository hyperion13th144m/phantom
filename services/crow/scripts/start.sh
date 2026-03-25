#!/bin/bash

exec uv run uvicorn crow.server:app --host 0.0.0.0 --reload
