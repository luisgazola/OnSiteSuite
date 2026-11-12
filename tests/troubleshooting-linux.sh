#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
folder="$("$ROOT/onsite.sh" --tests troubleshooting --symptom sem_internet --quiet --output "$TMP")"
jq -e '.schemaVersion=="2.0" and .version=="2.1.0" and .summary.total==1 and
  .tests[0].id=="troubleshooting" and .tests[0].status=="INCONCLUSIVO" and
  (.tests[0].evidence.details|length>15)' "$folder/relatorio.json" >/dev/null
folder="$("$ROOT/onsite.sh" --tests troubleshooting --symptom sintoma_desconhecido --quiet --output "$TMP")"
jq -e '.tests[0].status=="INCONCLUSIVO" and (.tests[0].summary|contains("sem fluxo"))' "$folder/relatorio.json" >/dev/null
printf 'OK: troubleshooting após consolidação de configurações.\n'
