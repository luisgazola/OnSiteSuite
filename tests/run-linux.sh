#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for test in check-catalog equipment-linux architecture-linux smoke-linux contract-linux troubleshooting-linux cleanup-linux; do
  bash "$ROOT/tests/$test.sh"
done

bash "$ROOT/tests/usb-monitor-linux.sh"
bash "$ROOT/tests/usb-analysis-linux.sh"
bash "$ROOT/tests/terminal-linux.sh"
bash "$ROOT/tests/printing-linux.sh"
printf 'OK: suíte completa Linux v2.2.0.\n'
