#!/usr/bin/env bash
# Controller: interpreta parâmetros, solicita serviços e decide o fluxo de tela.
ons_main() {
 local ROOT_DIR="$1"; shift
 local VERSION catalog DEFAULT ONLINE=0 LIST=0 INFO_ONLY=0 SHOW_INFO=0 INTERACTIVE=0 ALL=0
 local PRINT_QUEUE='' CONFIRM_PRINT=0 TESTS='' CLIENT='' TICKET='' TECHNICIAN='' SERIAL='' SYMPTOM=''
 local OUT="$ROOT_DIR/Reports" QUIET=0 EQUIPMENT_JSON TMP results_file folder
 VERSION="$(tr -d '\r\n' < "$ROOT_DIR/VERSION")"
 catalog="$ROOT_DIR/config/tests.json"
 DEFAULT='system,cpu,memory,storage,battery,network,usb,printer,drivers,security'
 while (($#)); do
  case "$1" in
   --list-tests) LIST=1; shift ;; --all) ALL=1; shift ;; --interactive) INTERACTIVE=1; shift ;;
   --info) INFO_ONLY=1; shift ;; --show-info) SHOW_INFO=1; shift ;;
   --online) ONLINE=1; shift ;; --yes-print) CONFIRM_PRINT=1; shift ;; --quiet) QUIET=1; shift ;;
   --tests|--client|--ticket|--technician|--serial|--symptom|--output|--print-test)
      (($#>=2)) || { printf 'Faltou valor para %s\n' "$1" >&2; return 2; }
      case "$1" in
       --tests) TESTS="$2" ;; --client) CLIENT="$2" ;; --ticket) TICKET="$2" ;;
       --technician) TECHNICIAN="$2" ;; --serial) SERIAL="$2" ;; --symptom) SYMPTOM="$2" ;;
       --output) OUT="$2" ;; --print-test) PRINT_QUEUE="$2" ;;
      esac; shift 2 ;;
   --help|-h) ons_usage; return 0 ;;
   *) printf 'Opção desconhecida: %s\n' "$1" >&2; ons_usage >&2; return 2 ;;
  esac
 done
 command -v jq >/dev/null 2>&1 || { printf 'Erro: jq é obrigatório (apt / dnf / pacman install jq).\n' >&2; return 3; }
 if ((LIST)); then ons_catalog_list "$catalog"; return 0; fi
 if [[ -n "$PRINT_QUEUE" && "$CONFIRM_PRINT" != 1 ]]; then
  printf 'Recusado: --print-test exige --yes-print (confirma saída física de papel).\n' >&2; return 2
 fi
 if [[ -n "$PRINT_QUEUE" && "$PRINT_QUEUE" =~ [[:cntrl:]] ]]; then
   printf 'Nome de fila inválido.\n' >&2; return 2
 fi
 ((ALL)) && TESTS="$(ons_catalog_passive "$catalog")"
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
   if ! ons_select_tests "$TESTS" "$VERSION" "$catalog"; then return 0; fi
   TESTS="$ONS_SELECTED_TESTS"
 fi
 ons_catalog_validate "$catalog" "$TESTS" || return 2
 [[ -n "${EQUIPMENT_JSON:-}" ]] || EQUIPMENT_JSON="$(ons_collect_equipment)"
 TMP="$(mktemp -d "${TMPDIR:-/tmp}/onsitesuite.XXXXXXXX")"
 ONS_TEMP_DIR="$TMP"
 trap 'ons_cleanup' EXIT
 results_file="$TMP/results.jsonl"
 ons_run_tests "$catalog" "$TESTS" "$results_file" "$TMP" "$ONLINE" "$SYMPTOM" "$ROOT_DIR" "$QUIET" ons_progress ons_prompt_checklist
 if [[ -n "$PRINT_QUEUE" ]]; then ons_run_print_test "$PRINT_QUEUE" "$VERSION" "$TMP" "$results_file" ons_submit_print_job; fi
 folder="$(ons_write_reports "$OUT" "$VERSION" "$EQUIPMENT_JSON" "$CLIENT" "$TICKET" "$TECHNICIAN" "$SERIAL" "$ONLINE" "$results_file")"
 if ((QUIET)); then printf '%s\n' "$folder"; else ons_report_saved "$folder/relatorio.json" "$folder"; fi
}
