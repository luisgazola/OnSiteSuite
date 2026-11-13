#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf -- "$TMP"' EXIT
source "$ROOT/src/linux/Services/UsbAnalysisService.sh"
cat > "$TMP/events.jsonl" <<'DATA'
{"time":"2026-01-01T00:00:00Z","event":"INICIO","device":"Dispositivos iniciais: 1"}
{"time":"2026-01-01T00:00:01Z","event":"DESCONECTADO","device":"1-1|abcd:1234|Dispositivo de teste"}
{"time":"2026-01-01T00:00:03Z","event":"CONECTADO","device":"1-1|abcd:1234|Dispositivo de teste"}
{"time":"2026-01-01T00:00:05Z","event":"CONECTADO","device":"1-2|ffff:8888|Outro dispositivo"}
{"time":"2026-01-01T00:00:07Z","event":"FIM","device":"Amostras: 4; conectados: 2; desconectados: 1"}
DATA
printf '1-1|abcd:1234|Dispositivo de teste\n' > "$TMP/initial"
printf '1-1|abcd:1234|Dispositivo de teste\n1-2|ffff:8888|Outro dispositivo\n' > "$TMP/final"
ons_usb_analyze "$TMP/events.jsonl" "$TMP/initial" "$TMP/final" 0.5 4 2.2.0 "$TMP/usb-resumo.json"
jq -e '.product=="OnSiteSuite" and .version=="2.2.0" and .schemaVersion=="1.0" and
  .collectionMethod=="usb_sysfs_periodic_snapshot" and .metrics.reconnections==1 and
  .metrics.disconnections==1 and .metrics.connections==2 and .metrics.affectedDevices==2 and
  (.devices|length)==2 and .devices[0].key=="1-1|abcd:1234" and
  .devices[0].initialPresent and .devices[0].finalPresent and
  .devices[1].initialPresent==false and .devices[1].finalPresent' "$TMP/usb-resumo.json" >/dev/null
# Integração real com o monitor, sem depender de temporização de hotplug simulada.
mkdir -p "$TMP/sysfs/2-3"
printf 'abcd\n' > "$TMP/sysfs/2-3/idVendor"
printf '9988\n' > "$TMP/sysfs/2-3/idProduct"
printf 'Inventário de teste\n' > "$TMP/sysfs/2-3/product"
ONS_USB_SYSFS="$TMP/sysfs" "$ROOT/onsite.sh" --usb-monitor --foreground --usb-interval 0.2 --usb-samples 2 --output "$TMP/reports" > "$TMP/stdout"
first="$(find "$TMP/reports" -name usb-resumo.json -print -quit)"
[[ -s "$first" ]]
jq -e '.metrics.reconnections==0 and .metrics.affectedDevices==0 and .initialDeviceCount==1' "$first" >/dev/null
json="$(dirname "$first")/relatorio.json"
jq -e '.schemaVersion=="2.0" and .version=="2.2.0" and .tests[0].id=="usb_monitor"' "$json" >/dev/null
ONS_USB_SYSFS="$TMP/sysfs" "$ROOT/onsite.sh" --usb-monitor --foreground --usb-interval 0.2 --usb-samples 2 --usb-baseline "$TMP/usb-resumo.json" --output "$TMP/compare" >/dev/null
comparison="$(find "$TMP/compare" -name usb-comparacao.json -print -quit)"
[[ -s "$comparison" ]]
jq -e '.comparisonType=="USB_SESSION_DELTA" and .reference.version=="2.2.0" and
  .delta.reconnections==-1 and .current.intervalSeconds==0.2' "$comparison" >/dev/null
if ONS_USB_SYSFS="$TMP/sysfs" "$ROOT/onsite.sh" --usb-monitor --foreground --usb-interval 0.2 --usb-samples 1 --usb-baseline "$TMP/absent.json" --output "$TMP/nope" >"$TMP/rejected" 2>&1; then
  printf 'Falha: baseline inexistente aceita.\n' >&2; exit 1
fi
printf 'OK: estatísticas USB determinísticas, integração, comparação de sessões e baseline inválida.\n'
