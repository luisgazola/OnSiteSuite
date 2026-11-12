#!/usr/bin/env bash
# OnSiteSuite 2.0.3 — coletor de identificação somente leitura.
# Dependências: Bash, jq; utilitários básicos quando presentes. Sem rede/elevação.

ons_clean() {
  # Dados de firmware podem ter caracteres de controle; nunca executar conteúdo.
  local val
  val="$(printf '%s' "${1:-}" | tr '\r\n\t' '   ' | LC_ALL=C tr -d '\000-\010\013\014\016-\037\177' | cut -c 1-160)"
  case "${val,,}" in
    ''|'none'|'unknown'|'not specified'|'not available'|'n/a'|'na'|'0'|'default string'|\
    'to be filled by o.e.m.'|'to be filled by oem'|'system serial number'|'system product name'|\
    'invalid'|'no asset tag'|'not applicable') printf 'Não identificado' ;;
    *) printf '%s' "$val" ;;
  esac
}
ons_dmi() {
  local key="$1" value=''
  if [[ -r "/sys/class/dmi/id/$key" ]]; then
    value="$(head -c 256 "/sys/class/dmi/id/$key" 2>/dev/null || true)"
  fi
  ons_clean "$value"
}
ons_chassis_type() {
  local chassis="$1"
  chassis="${chassis%% *}"
  case "$chassis" in
    13) printf 'AIO (All-in-One)' ;;
    8|9|10|11|14|30|31|32) printf 'Notebook' ;;
    3|4|5|6|7|15|16) printf 'Desktop' ;;
    *) printf 'Não identificado' ;;
  esac
}
ons_linux_os() {
  if [[ -r /etc/os-release ]]; then
    ( . /etc/os-release; ons_clean "${PRETTY_NAME:-${NAME:-Linux}}" )
  else
    printf 'Linux (%s)' "$(uname -r 2>/dev/null || printf '?')"
  fi
}
ons_linux_cpu() {
  local text=''
  if [[ -r /proc/cpuinfo ]]; then
    text="$(awk -F: '/^model name[[:space:]]*:/ {sub(/^[[:space:]]*/,"",$2); print $2; exit} /^Hardware[[:space:]]*:/ {sub(/^[[:space:]]*/,"",$2); print $2; exit}' /proc/cpuinfo)"
  fi
  ons_clean "$text"
}
ons_linux_memory() {
  local kb=''
  [[ -r /proc/meminfo ]] && kb="$(awk '/^MemTotal:/ {print $2; exit}' /proc/meminfo)"
  if [[ "$kb" =~ ^[0-9]+$ ]] && ((kb>0)); then
    awk -v n="$kb" 'BEGIN {printf "%.1f GiB", n/1048576}'
  else
    printf 'Não identificado'
  fi
}
ons_linux_storage() {
  if ! command -v lsblk >/dev/null 2>&1; then printf 'Não identificado'; return; fi
  local text
  # TYPE no final; funciona com modelo contendo espaços.
  text="$(lsblk -dn -o NAME,SIZE,MODEL,TYPE 2>/dev/null | awk '$NF=="disk" {name=$1; size=$2; model=""; for(i=3;i<NF;i++) model=model (model?" ":"") $i; print name " " size (model?" (" model ")":"")}' | head -n 4 | paste -sd ';' - | sed 's/;/; /g' || true)"
  ons_clean "$text"
}

ons_collect_equipment() {
  local system serial service brand model chassis cpu memory storage os
  os="$(ons_linux_os)"
  brand="$(ons_dmi sys_vendor)"
  model="$(ons_dmi product_name)"
  serial="$(ons_dmi product_serial)"
  chassis="$(ons_chassis_type "$(ons_dmi chassis_type)")"
  service='Não identificado'
  if [[ "${brand,,}" == *dell* && "$serial" != 'Não identificado' ]]; then service="$serial"; fi
  cpu="$(ons_linux_cpu)"; memory="$(ons_linux_memory)"; storage="$(ons_linux_storage)"
  jq -cn --arg os "$os" --arg serial "$serial" --arg serviceTag "$service" \
    --arg brand "$brand" --arg model "$model" --arg type "$chassis" \
    --arg cpu "$cpu" --arg memory "$memory" --arg storage "$storage" \
    '{sistemaOperacional:$os,numeroSerie:$serial,serviceTag:$serviceTag,marca:$brand,modelo:$model,
      tipo:$type,processador:$cpu,memoria:$memory,armazenamento:$storage}'
}
