#!/usr/bin/env bash
# Executa casos de uso de diagnóstico sem UI ou persistência de laudos.
# Dependências explícitas na composição: adapters (probe_*) e contrato make_result.
ons_dispatch_probe() {
 case "$1" in
  system) probe_system ;; cpu) probe_cpu ;; memory) probe_memory ;; storage) probe_storage ;;
  smart) probe_smart ;; battery) probe_battery ;; network) probe_network ;;
  usb) probe_usb ;; printer) probe_printer ;; drivers) probe_drivers ;;
  audio) probe_audio ;; display) probe_display ;; logs) probe_logs ;;
  security) probe_security ;; checklist) probe_checklist ;; troubleshooting) probe_troubleshooting ;;
  *) make_result 'NAO_SUPORTADO' 'Teste desconhecido' '' '' ;;
 esac
}
ons_run_one_probe() {
 local id="$1" title="$2" result_path="$3" errors_path="$4"
 local CURRENT_TEST="$id" CURRENT_TITLE="$title"
 if ! ons_dispatch_probe "$id" > "$result_path" 2> "$errors_path"; then
   make_result 'INCONCLUSIVO' 'Falha ao executar o coletor' "$(head -c 1000 "$errors_path")" 'Verifique permissões e dependências específicas do teste.' > "$result_path"
 fi
 if ! ons_result_valid "$result_path" "$id"; then
   make_result 'INCONCLUSIVO' 'Resposta de coletor inválida' '' 'Consulte log técnico do teste.' > "$result_path"
 fi
}
ons_run_tests() {
 local catalog="$1" ids_csv="$2" results_file="$3" tmp_dir="$4" online="$5" symptom="$6" root="$7" quiet="$8" progress_cb="$9"
 local ONS_CHECKLIST_PROMPT="${10}"
 local ONLINE="$online" SYMPTOM="$symptom" ROOT_DIR="$root"
 local id title
 local -a selected
 IFS=',' read -r -a selected <<<"$ids_csv"
 : > "$results_file"
 for id in "${selected[@]}"; do
   title="$(ons_catalog_title "$catalog" "$id")"
   if ((quiet == 0)) && [[ -n "$progress_cb" ]]; then "$progress_cb" "$id" "$title"; fi
   ons_run_one_probe "$id" "$title" "$tmp_dir/result.json" "$tmp_dir/probe-errors.log"
   cat "$tmp_dir/result.json" >> "$results_file"
 done
}
ons_run_print_test() {
 local queue="$1" version="$2" tmp_dir="$3" results_file="$4" submit_cb="$5" output status summary recommendation
 local CURRENT_TEST='print_test' CURRENT_TITLE='Página de teste de impressora (autorizada)'
 if ! command -v lp >/dev/null 2>&1; then
   make_result 'NAO_SUPORTADO' 'Cliente de impressão lp ausente' '' 'Instale o cliente CUPS.' >> "$results_file"
   return
 fi
 printf 'OnSiteSuite %s - Teste de impressao\nData UTC: %s\nFila: %s\n\nVerifique qualidade, alinhamento e alimentacao.\n' \
   "$version" "$(date -u +%FT%TZ)" "$queue" > "$tmp_dir/print.txt"
 if output="$("$submit_cb" "$queue" "$tmp_dir/print.txt" 2>&1)"; then
   status='INCONCLUSIVO'; summary='Job enviado; resultado físico requer conferência'; recommendation='Confirme visualmente se o papel foi impresso corretamente.'
 else
   status='ATENCAO'; summary='Falha ao enviar job de impressão'; recommendation='Verifique fila, cabo, interface e status da impressora.'
 fi
 make_result "$status" "$summary" "$output" "$recommendation" >> "$results_file"
}
