#!/usr/bin/env bash
set -Eeuo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"
export PYTHONPATH="${repository_root}/src${PYTHONPATH:+:${PYTHONPATH}}"

python -m ruff check src tests
python -m mypy src
python -m pytest
python -m build --wheel

for stack in infra/azure infra/databricks; do
  terraform -chdir="$stack" fmt -check -recursive
  terraform -chdir="$stack" init -backend=false -input=false
  terraform -chdir="$stack" validate
done

if command -v databricks >/dev/null 2>&1 && [[ -n "${DATABRICKS_HOST:-}" ]]; then
  databricks bundle validate --target dev \
    --var="runtime_service_principal=${DATABRICKS_CLIENT_ID:-local-validation}"
else
  printf 'Skipping live bundle validation: Databricks CLI or DATABRICKS_HOST is unavailable.\n'
fi
