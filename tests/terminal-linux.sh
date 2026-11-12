#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/sysfs/2-1"
printf '1234\n' > "$TMP/sysfs/2-1/idVendor"
printf '5678\n' > "$TMP/sysfs/2-1/idProduct"
printf 'Dispositivo de teste\n' > "$TMP/sysfs/2-1/product"
cat > "$TMP/bin/kgx" <<'KGX'
#!/usr/bin/env bash
# Emulador simulado: verifica --command e executa o worker somente por amostras finitas.
[[ "$1" == '--command' && "$#" -eq 2 ]] || exit 9
printf '%s\n' "$2" > "$ONS_TERMINAL_ARGS"
bash -c "$2" > /dev/null
KGX
chmod +x "$TMP/bin/kgx"
for choice in kgx auto; do
 dir="$TMP/output-$choice"
 args_file="$TMP/args-$choice"
 PATH="$TMP/bin:$PATH" WAYLAND_DISPLAY='wayland-1' ONS_TERMINAL_ARGS="$args_file" ONS_USB_SYSFS="$TMP/sysfs" \
 "$ROOT/onsite.sh" --usb-monitor --usb-terminal "$choice" --usb-interval 0.2 --usb-samples 2 --output "$dir" >/dev/null
 for _ in $(seq 1 60); do
   [[ -f "$args_file" && -n "$(find "$dir" -name usb-eventos.jsonl -print -quit 2>/dev/null)" ]] && break
   sleep 0.1
 done
 [[ -s "$args_file" ]]
 grep -F -- '--usb-monitor' "$args_file" >/dev/null
 grep -F -- '--foreground' "$args_file" >/dev/null
 [[ "$(find "$dir" -name relatorio.json | wc -l)" -eq 1 ]]
 json="$(find "$dir" -name relatorio.json -print -quit)"
 jq -e '.version=="2.1.0" and .tests[0].id=="usb_monitor"' "$json" >/dev/null
 [[ -s "$(dirname "$json")/usb-eventos.jsonl" ]]
done
if WAYLAND_DISPLAY='wayland-1' "$ROOT/onsite.sh" --usb-monitor --usb-terminal fake --usb-samples 1 >"$TMP/err" 2>&1; then
  echo 'FAIL: terminal desconhecido aceito' >&2; exit 1
fi
grep -F 'Terminal invalido' "$TMP/err" >/dev/null
printf 'OK: kgx selecionado e automatico, args protegidos, relatorios e terminal invalido.\n'
