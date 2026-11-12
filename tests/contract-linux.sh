#!/usr/bin/env bash
# Contrato de relatório v2: opcionalmente validado por Python jsonschema.
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
folder="$("$ROOT/onsite.sh" --tests system --quiet --output "$TMP")"
file="$folder/relatorio.json"
jq -e '.schemaVersion=="2.0" and .product=="OnSiteSuite" and .version=="2.0.2" and
  .equipamento.numeroSerie and (.tests|length==1) and .summary.total==1' "$file" >/dev/null
if python3 -c 'import jsonschema' >/dev/null 2>&1; then
 python3 - "$ROOT/config/report.schema.json" "$file" <<'PY'
import json,sys
from jsonschema import Draft202012Validator
schema=json.load(open(sys.argv[1],encoding='utf-8'))
data=json.load(open(sys.argv[2],encoding='utf-8'))
Draft202012Validator(schema).validate(data)
PY
 echo 'OK: contrato JSON 2.0 + JSON Schema 2020-12.'
else
 echo 'OK: contrato JSON 2.0 (jsonschema Python opcional não instalado).'
fi
