#!/usr/bin/env bash
set -Eeuo pipefail

cli_version="${DATABRICKS_CLI_VERSION:-1.15.0}"
install_root="${DATABRICKS_CLI_INSTALL_DIR:-$HOME/.local/bin}"
operating_system="$(uname -s | tr '[:upper:]' '[:lower:]')"
architecture="$(uname -m)"

case "$architecture" in
  x86_64) architecture="amd64" ;;
  arm64|aarch64) architecture="arm64" ;;
  *) printf 'Unsupported architecture: %s\n' "$architecture" >&2; exit 1 ;;
esac

case "$operating_system" in
  linux|darwin) ;;
  *) printf 'Unsupported operating system: %s\n' "$operating_system" >&2; exit 1 ;;
esac

archive="databricks_cli_${cli_version}_${operating_system}_${architecture}.tar.gz"
release_base="https://github.com/databricks/cli/releases/download/v${cli_version}"

mkdir -p "$install_root"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT

curl --fail --silent --show-error --location \
  "$release_base/$archive" --output "$temporary_directory/$archive"
curl --fail --silent --show-error --location \
  "$release_base/databricks_cli_${cli_version}_SHA256SUMS" \
  --output "$temporary_directory/SHA256SUMS"

(
  cd "$temporary_directory"
  grep "  ${archive}$" SHA256SUMS >SELECTED_SHA256SUM
  shasum -a 256 --check SELECTED_SHA256SUM
  tar -xzf "$archive"
)

install -m 0755 "$temporary_directory/databricks" "$install_root/databricks"
"$install_root/databricks" version
