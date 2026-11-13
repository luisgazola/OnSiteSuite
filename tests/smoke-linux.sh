#!/usr/bin/env bash
# Read-only automated smoke tests for OnSiteSuite Linux; no network or printing.
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
command -v jq >/dev/null
"$ROOT/onsite.sh" --info > "$TMP/info"
grep -q 'OnSiteSuite v2.2.0 | EXCELSIOR' "$TMP/info"
grep -q 'IDENTIFICAÇÃO DO EQUIPAMENTO' "$TMP/info"
"$ROOT/onsite.sh" --list-tests | grep -q '^cpu'
"$ROOT/onsite.sh" --tests system,memory,usb,printer \
  --client '<script>alert(1)</script> & Empresa' --technician 'Tecnico & Cia' \
  --output "$TMP/reports" --quiet > "$TMP/output"
folder="$(cat "$TMP/output")"
[[ -f "$folder/relatorio.json" && -f "$folder/relatorio.html" && -f "$folder/relatorio.txt" ]]
jq -e '.product=="OnSiteSuite" and .version=="2.2.0" and .schemaVersion=="2.0" and .equipamento.sistemaOperacional and .equipamento.marca and .equipamento.numeroSerie and .summary.total==4 and (.tests|length==4)' "$folder/relatorio.json" >/dev/null
jq -e '.tests | all(.status=="OK" or .status=="INCONCLUSIVO" or .status=="ATENCAO" or .status=="NAO_SUPORTADO" or .status=="FALHA")' "$folder/relatorio.json" >/dev/null
# User-provided HTML must be encoded.
grep -q '&lt;script&gt;' "$folder/relatorio.html"
grep -q 'Excelsior Soluções em Tecnologia' "$folder/relatorio.html"
grep -q 'Service Tag:' "$folder/relatorio.txt"
if grep -Fq '<script>alert(1)</script>' "$folder/relatorio.html"; then echo 'HTML injection detected' >&2; exit 1; fi
# Unknown tests and unconfirmed physical print jobs must be rejected.
if "$ROOT/onsite.sh" --tests nonexistent --output "$TMP" > /dev/null 2>&1; then echo 'Unknown test accepted' >&2; exit 1; fi
if "$ROOT/onsite.sh" --tests system --print-test default --output "$TMP" > /dev/null 2>&1; then echo 'Unconfirmed print accepted' >&2; exit 1; fi
[[ "$(stat -c %a "$folder/relatorio.json")" == '600' ]]
echo 'OK: Linux CLI, reports, escaping, guardrails, permissions.'
