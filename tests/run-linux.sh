#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for test in check-catalog equipment-linux architecture-linux smoke-linux contract-linux troubleshooting-linux cleanup-linux; do
  bash "$ROOT/tests/$test.sh"
done
printf 'OK: suíte de regressão Linux v2.0.3 completa.\n'
