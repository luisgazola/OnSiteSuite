#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
jq -e '.schemaVersion == "2.0" and ([.tests[].id] | unique | length) == (.tests|length)' "$ROOT/config/tests.json" >/dev/null
jq -e 'all(.tests[]; (.id|test("^[a-z_]+$")) and (.kind=="read-only" or .kind=="interactive" or .kind=="guided"))' "$ROOT/config/tests.json" >/dev/null
bash -n "$ROOT/onsite.sh" "$ROOT/src/linux/runner.sh" "$ROOT/src/linux/probes.sh" "$ROOT/tests/smoke-linux.sh"
echo 'OK: catálogo e scripts validos'
