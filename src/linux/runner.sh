#!/usr/bin/env bash
# OnSiteSuite v2.0.1 — CLI Linux offline-first
set -Eeuo pipefail
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=probes.sh
source "$ROOT_DIR/src/linux/probes.sh"
# shellcheck source=equipment.sh
source "$ROOT_DIR/src/linux/equipment.sh"
umask 077
VERSION="$(tr -d '\r\n' < "$ROOT_DIR/VERSION")"
ONLINE=0
LIST=0
INFO_ONLY=0
SHOW_INFO=0
INTERACTIVE=0
ALL=0
PRINT_QUEUE=''
CONFIRM_PRINT=0
TESTS=''
CLIENT=''
TICKET=''
TECHNICIAN=''
SERIAL=''
SYMPTOM=''
OUT="$ROOT_DIR/Reports"
QUIET=0
CURRENT_TEST=''
CURRENT_TITLE=''
TMP=''

usage() {
cat <<'HELP'
OnSiteSuite 2.0.1 — diagnóstico local Linux
Uso: ./onsite.sh [opções]
  --list-tests                 Lista códigos de testes disponíveis
  --info                       Exibe identificação do equipamento e sai
  --show-info                  Mostra o painel também em execução não interativa
  --tests system,cpu,storage   Seleciona testes específicos
  --all                        Executa todas as sondagens passivas (exceto checklist)
  --interactive                Abre seleção de testes no terminal
  --online                     Autoriza sondagens de rede externas
  --client NOME                Cliente opcional
  --ticket CODIGO              OS/chamado opcional
  --technician NOME            Técnico opcional
  --serial SERIAL              Serial opcional (não coletado automaticamente)
  --symptom CODIGO             Guia: notebook_lento, sem_internet ou bateria
  --output DIRETORIO           Destino dos relatórios
  --print-test NOME_DA_FILA    Envia página de teste via CUPS, somente com --yes-print
  --yes-print                  Confirma explicitamente envio de página de teste
  --quiet                      Mostra apenas caminho do relatório
  --help                       Exibe esta ajuda
Sem opções, abre seleção se houver terminal; em automação executa conjunto padrão.
O programa não solicita sudo, não modifica o equipamento e não contacta redes sem --online.
HELP
}
needarg() { (($# >= 2)) || { printf 'Faltou valor para %s\n' "$1" >&2; exit 2; }; }
while (($#)); do
  case "$1" in
    --list-tests) LIST=1; shift ;; --all) ALL=1; shift ;; --interactive) INTERACTIVE=1; shift ;;
    --info) INFO_ONLY=1; shift ;; --show-info) SHOW_INFO=1; shift ;;
    --online) ONLINE=1; shift ;; --yes-print) CONFIRM_PRINT=1; shift ;; --quiet) QUIET=1; shift ;;
    --tests|--client|--ticket|--technician|--serial|--symptom|--output|--print-test)
      needarg "$@"; case "$1" in
        --tests) TESTS="$2" ;; --client) CLIENT="$2" ;; --ticket) TICKET="$2" ;;
        --technician) TECHNICIAN="$2" ;; --serial) SERIAL="$2" ;; --symptom) SYMPTOM="$2" ;; --output) OUT="$2" ;;
        --print-test) PRINT_QUEUE="$2" ;;
      esac; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Opção desconhecida: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done
if ! command -v jq >/dev/null 2>&1; then printf 'Erro: jq é obrigatório. Debian: apt install jq | Fedora: dnf install jq | Arch: pacman -S jq\n' >&2; exit 3; fi
if ((LIST)); then jq -r '.tests[] | "\(.id)\t\(.title) [\(.kind)]"' "$ROOT_DIR/config/tests.json"; exit 0; fi
if [[ -n "$PRINT_QUEUE" && "$CONFIRM_PRINT" != 1 ]]; then
  printf 'Recusado: --print-test exige --yes-print (confirma saída física de papel).\n' >&2; exit 2
fi
if [[ -n "$PRINT_QUEUE" && "$PRINT_QUEUE" =~ [[:cntrl:]] ]]; then printf 'Nome de fila inválido.\n' >&2; exit 2; fi
DEFAULT='system,cpu,memory,storage,battery,network,usb,printer,drivers,security'
if ((ALL)); then TESTS="$(jq -r '[.tests[] | select(.kind=="read-only") | .id] | join(",")' "$ROOT_DIR/config/tests.json")"; fi
if [[ -z "$TESTS" && "$INTERACTIVE" == 0 && -t 0 ]]; then INTERACTIVE=1; fi
if [[ -z "$TESTS" ]]; then TESTS="$DEFAULT"; fi

# Uma coleta por execução, antes do menu; os mesmos dados acompanham o laudo.
EQUIPMENT_JSON="$(ons_collect_equipment)"
if ((INFO_ONLY || (INTERACTIVE && QUIET == 0) || (SHOW_INFO && QUIET == 0))); then
  ons_show_equipment "$EQUIPMENT_JSON" "$VERSION"
fi
if ((INFO_ONLY)); then exit 0; fi

# Seleção interativa no terminal, sem obrigação de OS.
if ((INTERACTIVE)); then
  mapfile -t ids < <(jq -r '.tests[].id' "$ROOT_DIR/config/tests.json")
  declare -A chosen=()
  IFS=',' read -ra initial <<< "$TESTS"
  for id in "${initial[@]}"; do chosen["$id"]=1; done
  while :; do
    printf '\n--- MENU DE TESTES | OnSiteSuite v%s ---\n' "$VERSION"
    for i in "${!ids[@]}"; do
      id="${ids[$i]}"; [[ "${chosen[$id]:-}" == 1 ]] && mark='x' || mark=' '
      title="$(jq -r --arg id "$id" '.tests[] | select(.id==$id) | .title' "$ROOT_DIR/config/tests.json")"
      printf '%2d. [%s] %s\n' "$((i+1))" "$mark" "$title"
    done
    printf 'a=Todos os testes passivos | r=Executar | q=Sair\n'
    read -r -p 'Escolha: ' answer || exit 0
    case "$answer" in
      r|R) TESTS=''; for id in "${ids[@]}"; do [[ "${chosen[$id]:-}" == 1 ]] && TESTS+="${TESTS:+,}$id"; done; break ;;
      q|Q) exit 0 ;;
      a|A) while IFS= read -r id; do chosen["$id"]=1; done < <(jq -r '.tests[] | select(.kind == "read-only") | .id' "$ROOT_DIR/config/tests.json") ;;
      *) if [[ "$answer" =~ ^[0-9]+$ ]] && ((answer >= 1 && answer <= ${#ids[@]})); then
           id="${ids[$((answer-1))]}"; if [[ "${chosen[$id]:-}" == 1 ]]; then unset 'chosen[$id]'; else chosen["$id"]=1; fi
         else printf 'Opção inválida.\n'; fi ;;
    esac
  done
fi
[[ -n "$TESTS" ]] || { printf 'Nenhum teste selecionado.\n' >&2; exit 2; }
IFS=',' read -ra selected <<< "$TESTS"
((${#selected[@]} > 0)) || exit 2
for id in "${selected[@]}"; do
  if ! jq -e --arg id "$id" '.tests[] | select(.id==$id)' "$ROOT_DIR/config/tests.json" >/dev/null; then
    printf 'Teste desconhecido: %s\n' "$id" >&2; exit 2
  fi
done

make_result() {
  local status="$1" summary="$2" evidence="$3" recommendation="$4"
  jq -cn --arg id "$CURRENT_TEST" --arg title "$CURRENT_TITLE" \
    --arg status "$status" --arg summary "$summary" --arg evidence "$evidence" \
    --arg recommendation "$recommendation" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
  {id:$id,title:$title,status:$status,summary:$summary,
   evidence:{details:$evidence},recommendations:(if $recommendation=="" then [] else [$recommendation] end),
   collectedAt:$timestamp}'
}

TMP="$(mktemp -d "${TMPDIR:-/tmp}/onsitesuite.XXXXXXXX")"
cleanup() { [[ -n "$TMP" && -d "$TMP" ]] && rm -rf -- "$TMP"; }
trap cleanup EXIT
results_file="$TMP/results.jsonl"
: > "$results_file"

for id in "${selected[@]}"; do
  CURRENT_TEST="$id"
  CURRENT_TITLE="$(jq -r --arg id "$id" '.tests[] | select(.id==$id) | .title' "$ROOT_DIR/config/tests.json")"
  if ((QUIET == 0)); then printf '[%s] %s...\n' "$id" "$CURRENT_TITLE"; fi
  if ! run_probe "$id" > "$TMP/result.json" 2> "$TMP/probe-errors.log"; then
    make_result 'INCONCLUSIVO' 'Falha ao executar o coletor' "$(head -c 1000 "$TMP/probe-errors.log")" 'Verifique permissões e dependências específicas do teste.' > "$TMP/result.json"
  fi
  if ! jq -e '.id and .status and .evidence' "$TMP/result.json" >/dev/null 2>&1; then
    make_result 'INCONCLUSIVO' 'Resposta de coletor inválida' '' 'Consulte log técnico do teste.' > "$TMP/result.json"
  fi
  cat "$TMP/result.json" >> "$results_file"
done

if [[ -n "$PRINT_QUEUE" ]]; then
  CURRENT_TEST='print_test'; CURRENT_TITLE='Página de teste de impressora (autorizada)'
  if command -v lp >/dev/null 2>&1; then
    printf 'OnSiteSuite %s - Teste de impressao\nData UTC: %s\nFila: %s\n\nVerifique qualidade, alinhamento e alimentacao.\n' \
      "$VERSION" "$(date -u +%FT%TZ)" "$PRINT_QUEUE" > "$TMP/print.txt"
    if printout="$(lp -d "$PRINT_QUEUE" -t 'OnSiteSuite Teste' -- "$TMP/print.txt" 2>&1)"; then
      make_result 'INCONCLUSIVO' 'Job enviado; resultado físico requer conferência' "$printout" 'Confirme visualmente se o papel foi impresso corretamente.' >> "$results_file"
    else make_result 'ATENCAO' 'Falha ao enviar job de impressão' "$printout" 'Verifique fila, cabo, interface e status da impressora.' >> "$results_file"; fi
  else make_result 'NAO_SUPORTADO' 'Cliente de impressão lp ausente' '' 'Instale o cliente CUPS.' >> "$results_file"; fi
fi

date_path="$(date -u +%Y/%m/%d)"
label="$(printf '%s' "${TICKET:-sem-os}" | sed -E 's/[^[:alnum:]_-]+/_/g' | cut -c1-35)"
[[ -n "$label" ]] || label='sem-os'
folder="$OUT/$date_path/${label}-$(date -u +%H%M%S)-$$"
mkdir -p -- "$folder"
chmod 700 -- "$folder" || true
json="$folder/relatorio.json"

jq -n \
 --arg version "$VERSION" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
 --arg client "$CLIENT" --arg ticket "$TICKET" --arg technician "$TECHNICIAN" --arg serial "$SERIAL" \
 --arg hostname "$(hostname 2>/dev/null || true)" --arg os 'linux' --argjson online "$ONLINE" \
 --argjson equipment "$EQUIPMENT_JSON" --slurpfile tests "$results_file" '
 {schemaVersion:"2.0",product:"OnSiteSuite",version:$version,createdAt:$timestamp,
  platform:$os,host:$hostname,equipamento:$equipment,onlineChecksAuthorized:($online==1),
  atendimento:{cliente:$client,chamado:$ticket,tecnico:$technician,serial:$serial},
  tests:$tests,
  summary:{total:($tests|length),ok:([$tests[]|select(.status=="OK")]|length),
   atencao:([$tests[]|select(.status=="ATENCAO")]|length),
   falha:([$tests[]|select(.status=="FALHA")]|length),
   inconclusivo:([$tests[]|select(.status=="INCONCLUSIVO")]|length),
   naoSuportado:([$tests[]|select(.status=="NAO_SUPORTADO")]|length)},
  disclaimer:"Resultado diagnóstico auxiliar; não substitui validação física e julgamento profissional."}' > "$json"

jq -r '
"OnSiteSuite v\(.version) - Relatório técnico\nData UTC: \(.createdAt)\nHost: \(.host)\nMarca/Modelo: \(.equipamento.marca) / \(.equipamento.modelo)\nSerial: \(.equipamento.numeroSerie) | Service Tag: \(.equipamento.serviceTag)\nTipo: \(.equipamento.tipo)\nCPU/RAM/Discos: \(.equipamento.processador) / \(.equipamento.memoria) / \(.equipamento.armazenamento)\nCliente: \(.atendimento.cliente)\nChamado: \(.atendimento.chamado)\nTécnico: \(.atendimento.tecnico)\n\nResumo: \(.summary | tostring)\n",
(.tests[] | "\n[\(.status)] \(.title)\n\(.summary)\n\(.evidence.details)\nRecomendações: \(.recommendations|join("; "))")' "$json" > "$folder/relatorio.txt"

cat > "$folder/relatorio.html" <<'HTML'
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OnSiteSuite - Relatório técnico</title><style>
:root{color-scheme:light dark}*{box-sizing:border-box}body{font:16px/1.55 system-ui,Arial,sans-serif;max-width:1000px;margin:auto;padding:24px;background:#111827;color:#e5e7eb}
h1,h2{color:#f8fafc}section,.hero{border:1px solid #475569;background:#1e293b;padding:18px;border-radius:12px;margin:14px 0;overflow-wrap:anywhere}
small{color:#cbd5e1}.tag{display:inline-block;padding:3px 9px;border-radius:99px;background:#334155;font-weight:700}.OK{color:#86efac}.ATENCAO{color:#fde68a}.FALHA{color:#fca5a5}.INCONCLUSIVO,.NAO_SUPORTADO{color:#cbd5e1}
pre{white-space:pre-wrap;word-break:break-word;overflow-wrap:anywhere;background:#0f172a;border:1px solid #475569;padding:12px;border-radius:8px}footer{margin:22px 0;color:#94a3b8}a{color:#93c5fd}@media print{body{background:white;color:black}h1,h2{color:black}section,.hero,pre{background:white;color:black;border-color:#999}}
</style></head><body>
HTML
jq -r '"<header class=\"hero\"><h1>OnSiteSuite v\(.version|@html)</h1><p>Excelsior Soluções em Tecnologia · Laudo técnico · \(.createdAt|@html)</p><p>Host: \(.host|@html)<br>Marca: \(.equipamento.marca|@html)<br>Modelo: \(.equipamento.modelo|@html)<br>Número de série: \(.equipamento.numeroSerie|@html)<br>Service Tag: \(.equipamento.serviceTag|@html)<br>Tipo: \(.equipamento.tipo|@html)<br>Processador: \(.equipamento.processador|@html)<br>Memória: \(.equipamento.memoria|@html)<br>Armazenamento: \(.equipamento.armazenamento|@html)<br>Cliente: \(.atendimento.cliente|@html)<br>Chamado: \(.atendimento.chamado|@html)<br>Técnico: \(.atendimento.tecnico|@html)<br>Serial informado: \(.atendimento.serial|@html)</p><p>Testes: \(.summary.total) · OK: \(.summary.ok) · Atenção: \(.summary.atencao) · Inconclusivos: \(.summary.inconclusivo) · Não suportados: \(.summary.naoSuportado)</p></header>"' "$json" >> "$folder/relatorio.html"
jq -r '.tests[] | "<section><h2>\(.title|@html)</h2><span class=\"tag \(.status)\">\(.status)</span><p>\(.summary|@html)</p><pre>\(.evidence.details|@html)</pre><p><b>Orientação:</b> \((.recommendations|join("; "))|@html)</p></section>"' "$json" >> "$folder/relatorio.html"
printf '<footer>Resultados auxiliares: confirmar em campo antes de concluir reparos. Relatório local gerado pelo OnSiteSuite 2.0.1 · Excelsior Soluções em Tecnologia.</footer></body></html>\n' >> "$folder/relatorio.html"
chmod 600 -- "$json" "$folder/relatorio.txt" "$folder/relatorio.html" || true
if ((QUIET == 0)); then
  jq -r '"\nResumo: \(.summary.total) testes; OK=\(.summary.ok); atenção=\(.summary.atencao); inconclusivos=\(.summary.inconclusivo); não suportados=\(.summary.naoSuportado)"' "$json"
  printf 'Relatórios gerados em:\n%s\n' "$folder"
else printf '%s\n' "$folder"; fi
