#!/bin/bash

exec uv run uvicorn craw.server:app --host 0.0.0.0 --reload
