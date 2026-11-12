#!/usr/bin/env bash
# Testes isolados do contrato Service Layer e dependências substituíveis por doubles.
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$ROOT"
source "$ROOT/src/linux/App/Bootstrap.sh"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
catalog="$ROOT/config/tests.json"

# Adapter de laboratório (sem qualquer acesso a /sys, rede ou discos).
probe_system() { make_result OK 'Mock aprovado' 'Dados <script>alert(1)</script>' ''; }
probe_memory() { printf '{"id":"wrong","status":"OK"}\n'; }  # contrato inválido -> fallback
ons_run_tests "$catalog" 'system,memory' "$TMP/results.jsonl" "$TMP" 0 '' "$ROOT" 1 '' ''
jq -s -e 'length==2 and .[0].id=="system" and .[0].status=="OK" and
  .[1].id=="memory" and .[1].status=="INCONCLUSIVO" and
  .[1].summary=="Resposta de coletor inválida"' "$TMP/results.jsonl" >/dev/null

if ons_catalog_validate "$catalog" 'system,unknown' >/dev/null 2>&1; then
  echo 'Catálogo aceitou ID desconhecido' >&2; exit 1
fi
if ons_catalog_validate "$catalog" 'system,' >/dev/null 2>&1; then
  echo 'Catálogo aceitou vírgula vazia' >&2; exit 1
fi

fixture='{"sistemaOperacional":"Test","numeroSerie":"NE","serviceTag":"NE","marca":"Mock","modelo":"Mock","tipo":"Desktop","processador":"Fake","memoria":"8 GiB","armazenamento":"Nenhum"}'
folder="$(ons_write_reports "$TMP/reports" '2.0.3' "$fixture" '<script> & Cia' '' '' '' 0 "$TMP/results.jsonl")"
[[ -f "$folder/relatorio.json" && -f "$folder/relatorio.txt" && -f "$folder/relatorio.html" ]]
jq -e '.version=="2.0.3" and .schemaVersion=="2.0" and .summary.total==2 and
  .summary.ok==1 and .summary.inconclusivo==1 and .tests[1].id=="memory"' "$folder/relatorio.json" >/dev/null
grep -Fq '&lt;script&gt;' "$folder/relatorio.html"
! grep -Fq '<script>alert(1)</script>' "$folder/relatorio.html"
[[ "$(stat -c %a "$folder/relatorio.json")" == '600' ]]
printf 'OK: Service Layer, adapter mock, contrato de resultados e HTML seguro.\n'
