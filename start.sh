#!/usr/bin/env bash
set -euo pipefail

# Railpack entrypoint: start the ML_MODEL FastAPI service

# Use project-local venv to avoid polluting global envs (optional)
PYTHON_BIN="python3"
PIP_BIN="pip3"
if command -v python >/dev/null 2>&1; then PYTHON_BIN="python"; fi
if command -v pip >/dev/null 2>&1; then PIP_BIN="pip"; fi

export PYTHONUNBUFFERED=1

cd "ML_MODEL"

# Install dependencies (idempotent)
${PIP_BIN} install --upgrade pip wheel >/dev/null 2>&1 || true
${PIP_BIN} install -r requirements.txt

# Start FastAPI via Uvicorn
PORT_ENV=${PORT:-8000}
exec ${PYTHON_BIN} -m uvicorn app:app --host 0.0.0.0 --port "${PORT_ENV}" --no-server-header


