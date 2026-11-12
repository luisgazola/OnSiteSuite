#!/usr/bin/env bash
# Controller: interpreta parâmetros, solicita serviços e decide o fluxo de tela.
ons_main() {
 local ROOT_DIR="$1"; shift
 local VERSION catalog DEFAULT ONLINE=0 LIST=0 INFO_ONLY=0 SHOW_INFO=0 INTERACTIVE=0 ALL=0
 local PRINT_QUEUE='' CONFIRM_PRINT=0 PRINT_COUNT=1 PRINT_BRAND='Não identificado' PRINT_MODEL='Não identificado' PRINT_RAW=0 PRINT_CUT=0 CONFIRM_CUT=0 CUT_MODE='full' PRINT_COUNT_GIVEN=0
 local USB_MONITOR=0 USB_FOREGROUND=0 USB_INTERVAL=1 USB_SAMPLES=0 USB_TERMINAL='auto' TESTS='' CLIENT='' TICKET='' TECHNICIAN='' SERIAL='' SYMPTOM=''
 local OUT="$ROOT_DIR/Reports" QUIET=0 EQUIPMENT_JSON TMP results_file folder
 VERSION="$(tr -d '\r\n' < "$ROOT_DIR/VERSION")"
 catalog="$ROOT_DIR/config/tests.json"
 DEFAULT='system,cpu,memory,storage,battery,network,usb,printer,drivers,security'
 while (($#)); do
  case "$1" in
   --list-tests) LIST=1; shift ;; --all) ALL=1; shift ;; --interactive) INTERACTIVE=1; shift ;;
   --info) INFO_ONLY=1; shift ;; --show-info) SHOW_INFO=1; shift ;;
   --online) ONLINE=1; shift ;; --yes-print) CONFIRM_PRINT=1; shift ;; --quiet) QUIET=1; shift ;;
   --usb-monitor) USB_MONITOR=1; shift ;; --foreground) USB_FOREGROUND=1; shift ;;
   --escpos-raw) PRINT_RAW=1; shift ;; --cut-after-each) PRINT_CUT=1; shift ;; --yes-cut) CONFIRM_CUT=1; shift ;;
   --tests|--client|--ticket|--technician|--serial|--symptom|--output|--print-test|--print-count|--print-brand|--print-model|--cut-mode|--usb-interval|--usb-samples|--usb-terminal)
      (($#>=2)) || { printf 'Faltou valor para %s\n' "$1" >&2; return 2; }
      case "$1" in
       --tests) TESTS="$2" ;; --client) CLIENT="$2" ;; --ticket) TICKET="$2" ;;
       --technician) TECHNICIAN="$2" ;; --serial) SERIAL="$2" ;; --symptom) SYMPTOM="$2" ;;
       --output) OUT="$2" ;; --print-test) PRINT_QUEUE="$2" ;;
       --print-count) PRINT_COUNT="$2"; PRINT_COUNT_GIVEN=1 ;; --print-brand) PRINT_BRAND="$2" ;;
       --print-model) PRINT_MODEL="$2" ;; --cut-mode) CUT_MODE="$2" ;;
       --usb-interval) USB_INTERVAL="$2" ;; --usb-samples) USB_SAMPLES="$2" ;; --usb-terminal) USB_TERMINAL="$2" ;;
      esac; shift 2 ;;
   --help|-h) ons_usage; return 0 ;;
   *) printf 'Opção desconhecida: %s\n' "$1" >&2; ons_usage >&2; return 2 ;;
  esac
 done
 case "$USB_TERMINAL" in auto|kgx|gnome-terminal|konsole|xfce4-terminal|xterm) ;; *) printf 'Terminal invalido: %s\n' "$USB_TERMINAL" >&2; return 2 ;; esac
 command -v jq >/dev/null 2>&1 || { printf 'Erro: jq é obrigatório (apt / dnf / pacman install jq).\n' >&2; return 3; }
 if ((LIST)); then ons_catalog_list "$catalog"; return 0; fi
 if ! [[ "$USB_SAMPLES" =~ ^[0-9]+$ ]] || (( 10#$USB_SAMPLES > 100000 )); then printf 'Amostras USB inválidas (0..100000).\n' >&2; return 2; fi
 if ! [[ "$USB_INTERVAL" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! awk -v x="$USB_INTERVAL" 'BEGIN{exit !(x>=0.2 && x<=60)}'; then
   printf 'Intervalo USB inválido (0.2..60 segundos).\n' >&2; return 2
 fi
 if ((USB_MONITOR)); then
   if ((USB_FOREGROUND)); then ons_monitor_usb_foreground "$ROOT_DIR" "$OUT" "$VERSION" "$USB_INTERVAL" "$USB_SAMPLES"
   else ons_launch_usb_terminal "$ROOT_DIR" "$OUT" "$USB_INTERVAL" "$USB_SAMPLES" "$USB_TERMINAL"; fi
   return $?
 fi
 if ! [[ "$PRINT_COUNT" =~ ^[0-9]+$ ]] || ((10#$PRINT_COUNT < 1 || 10#$PRINT_COUNT > 100)); then printf 'Quantidade inválida: informe de 1 a 100 impressões.\n' >&2; return 2; fi
 if [[ "$CUT_MODE" != full && "$CUT_MODE" != partial ]]; then printf 'Corte inválido: full ou partial.\n' >&2; return 2; fi
 if [[ -z "$PRINT_QUEUE" ]] && ((PRINT_COUNT_GIVEN || PRINT_RAW || PRINT_CUT || CONFIRM_CUT)); then
   printf 'Para a sequência de impressão, informe --print-test FILA.\n' >&2; return 2
 fi
 if ((PRINT_CUT)) && ((PRINT_RAW == 0 || CONFIRM_CUT == 0)); then
   printf 'Guilhotina exige --escpos-raw --cut-after-each --yes-cut (compatibilidade confirmada).\n' >&2; return 2
 fi
 if [[ -n "$PRINT_QUEUE" ]] && [[ ! "$PRINT_QUEUE" =~ ^[a-zA-Z0-9._-]+$ ]]; then
   printf 'Nome de fila CUPS inválido.\n' >&2; return 2
 fi
 if [[ -n "$PRINT_QUEUE" && "$CONFIRM_PRINT" != 1 ]]; then
  printf 'Recusado: --print-test exige --yes-print (confirma saída física de papel).\n' >&2; return 2
 fi
 ((ALL)) && TESTS="$(ons_catalog_passive "$catalog")"
 if [[ -n "$PRINT_QUEUE" && -z "$TESTS" ]] && (( ALL == 0 )); then TESTS=printer; fi
 if [[ -z "$TESTS" && "$INTERACTIVE" == 0 && -t 0 && -t 1 ]]; then INTERACTIVE=1; fi
 [[ -n "$TESTS" ]] || TESTS="$DEFAULT"
 # Evita perder testes/relatórios por saída interativa e mantém o painel da v2.0.1.
 if ((INTERACTIVE)) && { [[ ! -t 0 ]] || [[ ! -t 1 ]]; }; then
   printf 'A seleção interativa requer terminal. Use --tests ou --all.\n' >&2; return 2
 fi
 if ((INFO_ONLY || INTERACTIVE || SHOW_INFO)); then
   EQUIPMENT_JSON="$(ons_collect_equipment)"
   if ((INFO_ONLY || QUIET == 0)); then ons_show_equipment "$EQUIPMENT_JSON" "$VERSION"; fi
   ((INFO_ONLY)) && return 0
 fi
 if ((INTERACTIVE)); then
   while :; do
     if ! ons_select_tests "$TESTS" "$VERSION" "$catalog"; then return 0; fi
     case "${ONS_MENU_ACTION:-tests}" in
       usb) ons_launch_usb_terminal "$ROOT_DIR" "$OUT" "$USB_INTERVAL" "$USB_SAMPLES" "$USB_TERMINAL" || true; continue ;;
       print)
         if ! ons_prompt_print_batch; then continue; fi
         PRINT_QUEUE="$ONS_PRINT_QUEUE"; PRINT_COUNT="$ONS_PRINT_COUNT"; PRINT_BRAND="$ONS_PRINT_BRAND";
         PRINT_MODEL="$ONS_PRINT_MODEL"; PRINT_RAW="$ONS_PRINT_RAW"; PRINT_CUT="$ONS_PRINT_CUT";
         CONFIRM_PRINT=1; CONFIRM_CUT="$ONS_PRINT_CUT"; TESTS='printer'; break ;;
       *) TESTS="$ONS_SELECTED_TESTS"; break ;;
     esac
   done
 fi
 ons_catalog_validate "$catalog" "$TESTS" || return 2
 [[ -n "${EQUIPMENT_JSON:-}" ]] || EQUIPMENT_JSON="$(ons_collect_equipment)"
 TMP="$(mktemp -d "${TMPDIR:-/tmp}/onsitesuite.XXXXXXXX")"
 ONS_TEMP_DIR="$TMP"
 trap 'ons_cleanup' EXIT
 results_file="$TMP/results.jsonl"
 ons_run_tests "$catalog" "$TESTS" "$results_file" "$TMP" "$ONLINE" "$SYMPTOM" "$ROOT_DIR" "$QUIET" ons_progress ons_prompt_checklist
 if [[ -n "$PRINT_QUEUE" ]]; then
   PRINT_COUNT="$((10#$PRINT_COUNT))"
   ons_run_print_batch "$PRINT_QUEUE" "$PRINT_COUNT" "$PRINT_BRAND" "$PRINT_MODEL" "$PRINT_RAW" "$PRINT_CUT" "$CUT_MODE" "$VERSION" "$TMP" "$results_file" ons_submit_print_job
 fi
 folder="$(ons_write_reports "$OUT" "$VERSION" "$EQUIPMENT_JSON" "$CLIENT" "$TICKET" "$TECHNICIAN" "$SERIAL" "$ONLINE" "$results_file")"
 if [[ -n "$PRINT_QUEUE" && -f "$TMP/ons-print.txt" ]]; then
   cp -- "$TMP/ons-print.txt" "$folder/comprovante-impressao.txt"
   chmod 600 "$folder/comprovante-impressao.txt" || true
 fi
 if ((QUIET)); then printf '%s\n' "$folder"; else ons_report_saved "$folder/relatorio.json" "$folder"; fi
}
