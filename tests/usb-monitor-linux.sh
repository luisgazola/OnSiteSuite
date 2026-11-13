#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/sysfs/1-1"
printf 'abcd\n' > "$TMP/sysfs/1-1/idVendor"
printf '1234\n' > "$TMP/sysfs/1-1/idProduct"
printf 'Dispositivo A\n' > "$TMP/sysfs/1-1/product"
(
 sleep 0.35
 mkdir -p "$TMP/sysfs/1-2"
 printf 'abcd\n' > "$TMP/sysfs/1-2/idVendor"
 printf '5678\n' > "$TMP/sysfs/1-2/idProduct"
 printf 'Dispositivo B\n' > "$TMP/sysfs/1-2/product"
 sleep 0.4
 rm -rf -- "$TMP/sysfs/1-1"
) &
ONS_USB_SYSFS="$TMP/sysfs" "$ROOT/onsite.sh" --usb-monitor --foreground --usb-interval 0.2 --usb-samples 7 --output "$TMP/reports" > "$TMP/stdout"
mapfile -t reports < <(find "$TMP/reports" -name relatorio.json)
[[ "${#reports[@]}" == 1 ]]
json="${reports[0]}"; folder="$(dirname -- "$json")"
jq -e '.version == "2.2.0" and .schemaVersion=="2.0" and .tests[0].id=="usb_monitor" and .summary.total==1' "$json" >/dev/null
[[ -s "$folder/usb-eventos.jsonl" ]]
jq -s -e 'map(.event) | index("CONECTADO")!=null and index("DESCONECTADO")!=null' "$folder/usb-eventos.jsonl" >/dev/null
jq -e '.tests[0].status=="ATENCAO"' "$json" >/dev/null
[[ -s "$folder/relatorio.txt" && -s "$folder/relatorio.html" ]]
# Testa especificamente a saída \q em terminal PTY, sem limite artificial de amostras.
if command -v script >/dev/null 2>&1; then
  printf '\\q\n' | ONS_USB_SYSFS="$TMP/sysfs" script -q -c "'$ROOT/onsite.sh' --usb-monitor --foreground --usb-interval 0.2 --output '$TMP/quit-reports'" /dev/null > "$TMP/quit-output" 2>&1
  [[ "$(find "$TMP/quit-reports" -name relatorio.json | wc -l)" -eq 1 ]]
fi
printf 'OK: monitor USB eventos, relatórios e saída \\q.\n'
