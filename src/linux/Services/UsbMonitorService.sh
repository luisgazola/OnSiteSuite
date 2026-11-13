#!/usr/bin/env bash
# Serviço de monitoramento USB: compara snapshots sem modificar hardware.
ons_monitor_usb_foreground() {
 local root="$1" out="$2" version="$3" interval="$4" max_samples="$5" launch_ack="${6:-}" baseline="${7:-}"
 local work prev curr events resultfile equipment folder input pending="" item samples=0 connected=0 disconnected=0
 local analysis compared
 local current_count status summary details
 [[ -t 0 && -t 1 || "$max_samples" -gt 0 ]] || {
   printf 'Erro: monitor interativo requer terminal. Use --usb-samples N somente para coleta limitada.\n' >&2; return 2;
 }
 mkdir -p -- "$out"
 work="$(mktemp -d "${TMPDIR:-/tmp}/ons-usb.XXXXXXXX")"
 prev="$work/previous"; curr="$work/current"; events="$work/usb-eventos.jsonl"; resultfile="$work/results.jsonl"; analysis="$work/usb-resumo.json"; compared="$work/usb-comparacao.json"
 : > "$events"; : > "$resultfile"
 ons_usb_snapshot > "$prev"
 cp -- "$prev" "$work/initial"
 current_count="$(wc -l < "$prev")"
 # Ack usado apenas pelo lançador gráfico para não reportar sucesso falso.
 if [[ -n "$launch_ack" ]]; then
   ( umask 077; : > "$launch_ack" ) || printf 'Aviso: falha ao confirmar abertura da sessão USB.\n' >&2
 fi
 ons_usb_event "$events" 'INICIO' "Dispositivos iniciais: $current_count"
 printf '\n=== OnSiteSuite v%s | EXCELSIOR SOLUÇÕES ===\n' "$version"
 printf 'MONITOR USB CONTINUO · Intervalo: %ss\n' "$interval"
 printf 'Dispositivos USB iniciais: %s\n' "$current_count"
 printf 'Digite \\q e pressione ENTER para terminar e gerar o laudo.\n\n'
 local stop=0
 trap 'stop=1' INT TERM
 while ((stop == 0)); do
   input=''
   if [[ -t 0 ]]; then
     if IFS= read -r -t "$interval" input; then
       if [[ "$input" == '\q' ]]; then stop=1; break; fi
       [[ -n "$input" ]] && printf 'Comando inválido. Para sair: \\q + ENTER\n'
     fi
   else sleep "$interval"; fi
   ons_usb_snapshot > "$curr"
   while IFS= read -r item; do
     [[ -n "$item" ]] || continue
     printf '[%s] CONECTADO: %s\n' "$(date +%H:%M:%S)" "$item"
     ons_usb_event "$events" 'CONECTADO' "$item"
     connected=$((connected+1))
   done < <(LC_ALL=C comm -13 "$prev" "$curr")
   while IFS= read -r item; do
     [[ -n "$item" ]] || continue
     printf '[%s] DESCONECTADO: %s\n' "$(date +%H:%M:%S)" "$item"
     ons_usb_event "$events" 'DESCONECTADO' "$item"
     disconnected=$((disconnected+1))
   done < <(LC_ALL=C comm -23 "$prev" "$curr")
   mv -f -- "$curr" "$prev"
   samples=$((samples+1))
   if ((samples % 30 == 0)); then printf "[%s] Monitor ativo: %s amostras, %s conexões, %s desconexões\n" "$(date +%H:%M:%S)" "$samples" "$connected" "$disconnected"; fi
   if (( max_samples > 0 && samples >= max_samples )); then break; fi
 done
 trap - INT TERM
 ons_usb_event "$events" 'FIM' "Amostras: $samples; conectados: $connected; desconectados: $disconnected"
 ons_usb_analyze "$events" "$work/initial" "$prev" "$interval" "$samples" "$version" "$analysis" || { printf 'Falha ao analisar monitor USB.
' >&2; rm -rf -- "$work"; return 3; }
 if [[ -n "$baseline" ]]; then
   ons_usb_compare "$analysis" "$baseline" "$compared" || { rm -rf -- "$work"; return 2; }
 fi
 local reconnects affected
 reconnects="$(jq -r '.metrics.reconnections' "$analysis")"
 affected="$(jq -r '.metrics.affectedDevices' "$analysis")"
 printf 'Resumo: %s dispositivo(s) alterados; %s reconexão(ões) observada(s).
' "$affected" "$reconnects"

 status='INCONCLUSIVO'
 if ((connected + disconnected > 0)); then status='ATENCAO'; fi
 summary="Monitoramento USB concluído: $samples amostras, $connected conexões, $disconnected desconexões e $reconnects reconexões observadas"
 details="Monitoramento por amostragem, intervalo ${interval}s. Dispositivos iniciais: $current_count. Eventos capturados: $((connected+disconnected)). Monitor não prova qualidade elétrica nem detecta eventos entre amostras.\n"
 details+="$(tail -n 30 "$events" 2>/dev/null)"
 local CURRENT_TEST='usb_monitor' CURRENT_TITLE='Monitoramento contínuo USB'
 make_result "$status" "$summary" "$details" 'Alterações repetidas podem indicar instabilidade: compare cabo, porta e dispositivo. Eventos muito breves podem não ser observados.' > "$resultfile"
 equipment="$(ons_collect_equipment)"
 folder="$(ons_write_reports "$out" "$version" "$equipment" '' '' '' '' 0 "$resultfile")"
 cp -- "$events" "$folder/usb-eventos.jsonl"
 cp -- "$analysis" "$folder/usb-resumo.json"
 if [[ -n "$baseline" ]]; then cp -- "$compared" "$folder/usb-comparacao.json"; fi
 chmod 600 "$folder/usb-eventos.jsonl" "$folder/usb-resumo.json" "$folder"/usb-comparacao.json 2>/dev/null || true
 rm -rf -- "$work"
 printf '\nMonitor encerrado. Laudo JSON, TXT e HTML: %s\nRegistro completo: %s/usb-eventos.jsonl\n' "$folder" "$folder"
}
