#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
jq -e '.schemaVersion == "2.0" and ([.tests[].id] | unique | length) == (.tests|length)' "$ROOT/config/tests.json" >/dev/null
jq -e 'all(.tests[]; (.id|test("^[a-z_]+$")) and (.kind=="read-only" or .kind=="interactive" or .kind=="guided"))' "$ROOT/config/tests.json" >/dev/null
while IFS= read -r -d '' file; do bash -n "$file"; done < <(find "$ROOT/src/linux" "$ROOT/tests" -name '*.sh' -print0)
bash -n "$ROOT/onsite.sh" "$ROOT/scripts/publish-github.sh"
echo 'OK: catálogo e scripts validos'
