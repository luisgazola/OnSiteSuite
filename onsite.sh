#!/usr/bin/env bash
# OnSiteSuite v2.0.3 — launcher Linux
set -Eeuo pipefail
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/src/linux/runner.sh" "$@"
