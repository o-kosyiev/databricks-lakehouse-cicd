#!/usr/bin/env bash
set -Eeuo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"
export PYTHONPATH="${repository_root}/src${PYTHONPATH:+:${PYTHONPATH}}"

python -m ruff check src tests
python -m mypy src
python -m pytest
python -m build --wheel

terraform fmt -check -recursive infra
for stack in infra/azure infra/databricks; do
  terraform -chdir="$stack" init -backend=false -input=false
  terraform -chdir="$stack" validate
done
