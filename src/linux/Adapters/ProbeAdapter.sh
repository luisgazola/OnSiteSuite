#!/usr/bin/env bash
# Linux adapters; all probes are read-only. No implicit sudo or network traffic.
# Adapter Linux: depende do contrato make_result (Domain/Result.sh).

safe_read() { local f="$1"; if [[ -r "$f" ]]; then head -c 12000 -- "$f" 2>/dev/null || true; fi; }
truncate_evidence() { head -c 12000; }

probe_system() {
  local os='desconhecido' hostname kernel machine boot='';
  [[ -r /etc/os-release ]] && os="$(. /etc/os-release; printf '%s %s' "${NAME:-Linux}" "${VERSION_ID:-}")"
  hostname="$(hostname 2>/dev/null || printf desconhecido)"
  kernel="$(uname -sr 2>/dev/null || printf desconhecido)"
  machine="$(uname -m 2>/dev/null || printf desconhecido)"
  [[ -d /sys/firmware/efi ]] && boot='UEFI' || boot='BIOS/indeterminado'
  make_result "OK" "Sistema: $os; kernel: $kernel" "$(printf 'Host: %s\nSistema: %s\nKernel: %s\nArquitetura: %s\nBoot: %s\n' "$hostname" "$os" "$kernel" "$machine" "$boot")" ''
}
probe_cpu() {
  local model cores load temp='indisponível' evidence
  model="$(grep -m1 -E 'model name|Hardware|Processor' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ *//' || true)"
  cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '?')"
  load="$(safe_read /proc/loadavg)"
  local temps=() f raw
  for f in /sys/class/thermal/thermal_zone*/temp; do
    [[ -r "$f" ]] || continue
    raw="$(safe_read "$f")"
    if [[ "$raw" =~ ^-?[0-9]+$ ]]; then temps+=("$(basename "$(dirname "$f")"): $((raw / 1000))°C"); fi
  done
  if ((${#temps[@]} > 0)); then temp="$(printf '%s; ' "${temps[@]}")"; fi
  evidence="$(printf 'Modelo: %s\nCPUs lógicas: %s\nLoad average: %s\nSensores: %s\n' "${model:-indisponível}" "$cores" "$load" "$temp")"
  [[ -n "$model" ]] && make_result "OK" "CPU identificada; temperaturas dependem de sensores" "$evidence" '' || make_result "INCONCLUSIVO" "Modelo de CPU indisponível" "$evidence" ''
}
probe_memory() {
  if [[ ! -r /proc/meminfo ]]; then make_result "NAO_SUPORTADO" "Dados de RAM indisponíveis" '' ''; return; fi
  local total available used pct detail
  total="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
  available="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"
  [[ "$total" =~ ^[0-9]+$ && "$available" =~ ^[0-9]+$ && "$total" -gt 0 ]] || { make_result "INCONCLUSIVO" "Memória não mensurável" '' ''; return; }
  used=$((total - available)); pct=$((used * 100 / total))
  detail="Total: $((total / 1024)) MiB; disponível: $((available / 1024)) MiB; uso estimado: ${pct}% (MemAvailable)."
  if ((pct >= 90)); then make_result "ATENCAO" "Utilização de RAM elevada (${pct}%)" "$detail" 'Verificar aplicativos e pressão de memória em múltiplas medições.'
  else make_result "OK" "Uso estimado de RAM: ${pct}%" "$detail" ''; fi
}
probe_storage() {
  if ! command -v lsblk >/dev/null 2>&1; then make_result "NAO_SUPORTADO" "lsblk indisponível" '' ''; return; fi
  local disks volumes
  disks="$(lsblk -o NAME,TYPE,SIZE,MODEL,TRAN,MOUNTPOINT -P 2>&1 | truncate_evidence || true)"
  volumes="$(df -hP 2>&1 | head -35 || true)"
  [[ -n "$disks" ]] && make_result "OK" "Dispositivos de armazenamento identificados (sem afirmar saúde)" "Discos:\n$disks\n\nVolumes:\n$volumes" 'Para saúde física, executar teste SMART separadamente.' || make_result "INCONCLUSIVO" "Nenhum dispositivo listado" "$volumes" ''
}
probe_smart() {
  if ! command -v smartctl >/dev/null 2>&1; then make_result "NAO_SUPORTADO" "smartmontools não instalado" '' 'Instale smartmontools; talvez seja necessário executar como administrador para ler SMART.'; return; fi
  if ! command -v lsblk >/dev/null 2>&1; then make_result "NAO_SUPORTADO" "lsblk indisponível" '' ''; return; fi
  local devices=() disk raw out count=0 fail=0 restricted=0
  mapfile -t devices < <(lsblk -dn -o PATH,TYPE 2>/dev/null | awk '$2=="disk" {print $1}' | head -8)
  ((${#devices[@]})) || { make_result "NAO_SUPORTADO" "Nenhum disco físico localizado" '' ''; return; }
  out=''
  for disk in "${devices[@]}"; do
    raw="$(smartctl -H "$disk" 2>&1 || true)"
    out+="$(printf '%s\n%s\n' "--- $disk ---" "$raw" | head -c 3000)"$'\n'
    if grep -Eqi 'Permission denied|access denied|Operation not permitted|must be root|permission' <<<"$raw"; then restricted=$((restricted+1))
    elif grep -Eqi 'SMART overall-health self-assessment test result: PASSED|SMART Health Status: OK|SMART overall-health.*PASSED' <<<"$raw"; then count=$((count+1))
    elif grep -Eqi 'FAILED|FAILING_NOW|SMART Health Status: BAD' <<<"$raw"; then fail=$((fail+1))
    fi
  done
  if ((fail > 0)); then make_result "ATENCAO" "SMART reportou possível falha em $fail disco(s)" "$out" 'Priorize backup antes de testes adicionais; considere substituir o dispositivo.'
  elif ((count > 0 && count + restricted == ${#devices[@]} && restricted == 0)); then make_result "OK" "SMART sem falha geral reportada ($count disco(s)); isso não garante ausência de falhas" "$out" 'Acompanhe atributos e histórico de erros; teste geral SMART não substitui diagnóstico completo.'
  else make_result "INCONCLUSIVO" "SMART indisponível ou não conclusivo para parte dos discos" "$out" 'Verifique permissões e suporte SMART; não interpretar ausência de resposta como saúde OK.'; fi
}
probe_battery() {
  local bats=() bat out='' now full design cycles status pct health
  for bat in /sys/class/power_supply/BAT*; do [[ -d "$bat" ]] && bats+=("$bat"); done
  ((${#bats[@]})) || { make_result "NAO_SUPORTADO" "Bateria não detectada" '' ''; return; }
  for bat in "${bats[@]}"; do
    now="$(safe_read "$bat/capacity")"; cycles="$(safe_read "$bat/cycle_count")"; status="$(safe_read "$bat/status")"
    full="$(safe_read "$bat/energy_full")"; design="$(safe_read "$bat/energy_full_design")"
    [[ -n "$full" ]] || full="$(safe_read "$bat/charge_full")"
    [[ -n "$design" ]] || design="$(safe_read "$bat/charge_full_design")"
    health='indisponível'
    if [[ "$full" =~ ^[0-9]+$ && "$design" =~ ^[0-9]+$ && "$design" -gt 0 ]]; then health="$((full * 100 / design))%"; fi
    out+="$(printf '%s: carga %s%%; estado %s; ciclos %s; capacidade estimada %s\n' "$(basename "$bat")" "${now:-?}" "${status:-?}" "${cycles:-?}" "$health")"
  done
  make_result "OK" "Bateria identificada (saúde estimada quando possível)" "$out" ''
}
probe_network() {
  local info gateway='' details status='OK' summary='Configuração de rede local coletada'
  if command -v ip >/dev/null 2>&1; then
    info="$(ip -brief address 2>&1 | head -25)"; gateway="$(ip -4 route show default 2>/dev/null | awk 'NR==1{print $3}')"
  else
    info="$(hostname -I 2>/dev/null || true)"; gateway="$(awk '$2=="00000000" {print $3}' /proc/net/route 2>/dev/null | head -1)"
  fi
  details="Interfaces: $info\nGateway: ${gateway:-não identificado}\nDNS local: $(head -10 /etc/resolv.conf 2>/dev/null || true)"
  if [[ "$ONLINE" == 1 ]]; then
    local gw_status='não executado' ip_status='não executado' dns_status='não executado'
    if command -v ping >/dev/null 2>&1; then
      [[ -n "$gateway" ]] && { ping -n -c 1 -W 2 "$gateway" >/dev/null 2>&1 && gw_status='respondeu' || gw_status='sem resposta'; }
      ping -n -c 1 -W 2 '1.1.1.1' >/dev/null 2>&1 && ip_status='respondeu' || ip_status='sem resposta'
    fi
    if command -v getent >/dev/null 2>&1; then getent hosts 'example.com' >/dev/null 2>&1 && dns_status='resolveu' || dns_status='sem resposta'; fi
    details+="\nOnline (autorizado): gateway=$gw_status; IP público=$ip_status; DNS=$dns_status"
    if [[ "$ip_status" != 'respondeu' || "$dns_status" != 'resolveu' ]]; then status='ATENCAO'; summary='Conectividade externa não confirmada (ICMP pode estar bloqueado)'; fi
  else details+=$'\nNenhuma sondagem externa realizada (modo offline).'; fi
  [[ -z "$info" ]] && { status='INCONCLUSIVO'; summary='Informações de rede local indisponíveis'; }
  make_result "$status" "$summary" "$details" 'Falhas de ICMP isoladas não comprovam interrupção do acesso à internet.'
}
probe_usb() {
  local item details='' number=0 vendor product label
  for item in /sys/bus/usb/devices/*; do
    [[ -r "$item/idVendor" && -r "$item/idProduct" ]] || continue
    vendor="$(safe_read "$item/idVendor")"; product="$(safe_read "$item/idProduct")"; label="$(safe_read "$item/product")"
    details+="$(printf '%s %s:%s %s\n' "$(basename "$item")" "$vendor" "$product" "${label:-sem nome}")"
    number=$((number+1)); ((number >= 60)) && break
  done
  if ((number)); then make_result "OK" "$number dispositivo(s) USB enumerado(s); estabilidade ainda não testada" "$details" 'Desconexões intermitentes exigem teste monitorado, troca de cabo e comparação de portas.'
  else make_result "INCONCLUSIVO" "Nenhum dispositivo USB enumerado" '' ''; fi
}
probe_printer() {
  if ! command -v lpstat >/dev/null 2>&1; then make_result "NAO_SUPORTADO" "Ferramentas CUPS (lpstat) não instaladas" '' 'Instale o cliente CUPS para consultar filas de impressão.'; return; fi
  local status
  status="$(lpstat -p -d 2>&1 | head -40 || true)"
  [[ "$status" == *"printer "* || "$status" == *"impressora "* ]] && make_result "OK" "Fila(s) de impressão encontradas; nenhuma página foi enviada" "$status" 'Disponibilidade de fila não garante comunicação física nem funcionamento da guilhotina.' || make_result "INCONCLUSIVO" "Nenhuma fila de impressão confirmada" "$status" ''
}
probe_drivers() {
  local out='' total=0 dev
  for dev in /sys/bus/pci/devices/*/driver; do [[ -L "$dev" ]] && total=$((total+1)); done
  out="Dispositivos PCI associados a driver: $total"
  if command -v lspci >/dev/null 2>&1; then out+=$'\n'; out+="$(lspci -k 2>&1 | head -70)"; fi
  if ((total)); then make_result "OK" "Associações de drivers PCI identificadas; não equivale a testar funcionamento" "$out" ''
  else make_result "INCONCLUSIVO" "Dados de driver insuficientes" "$out" ''; fi
}
probe_audio() {
  local cards=''
  cards="$(safe_read /proc/asound/cards)"
  if [[ -n "$cards" ]]; then make_result "OK" "Dispositivos de áudio enumerados; reprodução não testada" "$cards" 'Valide reprodução, microfone e saída selecionada manualmente.'
  else make_result "NAO_SUPORTADO" "Nenhum dispositivo ALSA visível" '' 'No PipeWire/Wayland, verificar dispositivos na ferramenta de áudio do desktop.'; fi
}
probe_display() {
  local out='' active=0 connector state
  for connector in /sys/class/drm/card*-*/status; do
    [[ -r "$connector" ]] || continue
    state="$(safe_read "$connector")"; out+="$(dirname "$connector" | xargs basename): $state"$'\n'
    [[ "$state" == 'connected' ]] && active=$((active+1))
  done
  if ((active)); then make_result "OK" "$active conexão(ões) de vídeo detectada(s); imagem não inspecionada" "$out" 'Use teste visual para verificar brilho, manchas, linhas e pixels.'
  else make_result "INCONCLUSIVO" "Monitores não identificados via DRM" "$out" ''; fi
}
probe_logs() {
  if ! command -v journalctl >/dev/null 2>&1; then make_result "NAO_SUPORTADO" "journalctl indisponível" '' ''; return; fi
  local out
  out="$(journalctl --no-pager --since '24 hours ago' -p err -n 25 -o short-iso 2>&1 | truncate_evidence || true)"
  if grep -Eqi 'No journal files were found|permission denied|Insufficient permissions' <<<"$out"; then make_result "INCONCLUSIVO" "Leitura dos logs indisponível por permissão ou configuração" "$out" 'Execute com as permissões autorizadas apenas se necessário.'
  elif [[ -n "$out" && "$out" != '-- No entries --' ]]; then make_result "ATENCAO" "Há registros de erro nas últimas 24 horas; requer interpretação" "$out" 'Correlacione horários e eventos com o defeito relatado.'
  else make_result "OK" "Nenhum erro acessível encontrado no intervalo" "$out" 'Ausência de logs não garante ausência de problemas.'; fi
}
probe_security() {
  local evidence='' status='INCONCLUSIVO'
  [[ -d /sys/firmware/efi ]] && evidence+='Firmware em modo UEFI; ' || evidence+='UEFI não detectado; '
  if command -v mokutil >/dev/null 2>&1; then evidence+="Secure Boot: $(mokutil --sb-state 2>&1 | head -1); "; fi
  if command -v firewall-cmd >/dev/null 2>&1; then evidence+="firewalld: $(firewall-cmd --state 2>&1 | head -1); "; fi
  if command -v ufw >/dev/null 2>&1; then evidence+="ufw: $(ufw status 2>&1 | head -1); "; fi
  [[ -r /proc/sys/kernel/randomize_va_space ]] && evidence+="ASLR: $(safe_read /proc/sys/kernel/randomize_va_space); "
  make_result "$status" "Indicadores parciais coletados; auditoria de segurança não realizada" "$evidence" 'A configuração de segurança exige avaliação contextual e verificações adicionais.'
}
