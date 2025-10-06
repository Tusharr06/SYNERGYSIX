#!/usr/bin/env bash
set -euo pipefail

# Agro Stick ML Model Service Startup Script

# Check if conda is available
if ! command -v conda >/dev/null 2>&1; then
    echo "Error: Conda is not installed or not in PATH"
    echo "Please install Miniconda or Anaconda first"
    exit 1
fi

# Check if environment exists, if not create it
if ! conda env list | grep -q "agro_stick"; then
    echo "Creating conda environment from environment.yaml..."
    conda env create -f environment.yaml
fi

# Activate environment
echo "Activating agro_stick environment..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate agro_stick

export PYTHONUNBUFFERED=1

cd "ML_MODEL"

# Install dependencies (idempotent)
${PIP_BIN} install --upgrade pip wheel >/dev/null 2>&1 || true
${PIP_BIN} install -r requirements.txt

# Start FastAPI via Uvicorn
PORT_ENV=${PORT:-8000}
exec ${PYTHON_BIN} -m uvicorn app:app --host 0.0.0.0 --port "${PORT_ENV}" --no-server-header


