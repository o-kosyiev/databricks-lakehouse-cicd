#!/usr/bin/env bash
set -Eeuo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-}"

if [[ ! "$target" =~ ^(dev|stage|prod)$ ]]; then
  printf 'Usage: %s <dev|stage|prod>\n' "$0" >&2
  exit 2
fi

: "${DATABRICKS_HOST:?DATABRICKS_HOST must be set by the deployment environment}"
: "${DATABRICKS_CLIENT_ID:?DATABRICKS_CLIENT_ID must identify the federated deployment principal}"

cd "$repository_root"
python -m build --wheel
databricks bundle validate --target "$target" \
  --var="runtime_service_principal=${DATABRICKS_CLIENT_ID}"
databricks bundle deploy --target "$target" --auto-approve \
  --var="runtime_service_principal=${DATABRICKS_CLIENT_ID}"
