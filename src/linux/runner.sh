#!/usr/bin/env bash
# Thin CLI entrypoint, v2.0.2. Sem lógica de negócio, apresentação ou persistência.
set -Eeuo pipefail
umask 077
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/src/linux/App/Bootstrap.sh"
ons_main "$ROOT_DIR" "$@"
