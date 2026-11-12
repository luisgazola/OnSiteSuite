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
