#!/usr/bin/env bash
# Linux: fotografia do sysfs, leitura somente; permite sysfs mockado em testes.
ons_usb_snapshot() {
 local base="${ONS_USB_SYSFS:-/sys/bus/usb/devices}" device path vid pid label
 for device in "$base"/*; do
  [[ -r "$device/idVendor" && -r "$device/idProduct" ]] || continue
  path="$(basename -- "$device")"
  vid="$(head -c 12 "$device/idVendor" 2>/dev/null || true)"
  pid="$(head -c 12 "$device/idProduct" 2>/dev/null || true)"
  label='Sem identificacao'
  [[ -r "$device/product" ]] && label="$(head -c 140 "$device/product" 2>/dev/null || true)"
  # Normaliza caracteres de controle para impedir falsificação de linhas no monitor/log.
  path="$(printf '%s' "$path" | LC_ALL=C tr -cd '[:alnum:].:_-')"
  vid="$(printf '%s' "$vid" | LC_ALL=C tr -cd '[:xdigit:]')"
  pid="$(printf '%s' "$pid" | LC_ALL=C tr -cd '[:xdigit:]')"
  label="$(printf '%s' "$label" | tr '\t\n\r|' '    ' | head -c 140)"
  printf '%s|%s:%s|%s\n' "$path" "$vid" "$pid" "$label"
 done | LC_ALL=C sort -u
}
ons_usb_event() {
 local file="$1" kind="$2" item="$3"
 jq -cn --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg type "$kind" --arg device "$item" \
   '{time:$time,event:$type,device:$device}' >> "$file"
}
