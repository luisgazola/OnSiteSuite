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
# Emulador estrito: --command é rejeitado (regressão do erro real no KGX Gentoo).
# O GNOME Console deve receber "-- bash script arg1 ...", sem shell reparse.
[[ "${1:-}" == '--' && "${2:-}" == 'bash' && "$#" -ge 5 ]] || {
  printf 'Faltando argumento para o --command (modo antigo recusado)\n' >&2
  exit 9
}
printf '%s\n' "$@" > "$ONS_TERMINAL_ARGS"
shift 2
bash "$@" > /dev/null
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
 jq -e '.version=="2.2.0" and .tests[0].id=="usb_monitor"' "$json" >/dev/null
 [[ -s "$(dirname "$json")/usb-eventos.jsonl" ]]
done
if WAYLAND_DISPLAY='wayland-1' "$ROOT/onsite.sh" --usb-monitor --usb-terminal fake --usb-samples 1 >"$TMP/err" 2>&1; then
  echo 'FAIL: terminal desconhecido aceito' >&2; exit 1
fi
grep -F 'Terminal invalido' "$TMP/err" >/dev/null
# O emulador pode existir e falhar; jamais informar abertura confirmada nesse caso.
mkdir -p "$TMP/bin-fail"
cat > "$TMP/bin-fail/kgx" <<'KGXFAIL'
#!/usr/bin/env bash
printf 'ERRO SIMULADO DO KGX: impossível abrir a janela\n' >&2
exit 27
KGXFAIL
chmod +x "$TMP/bin-fail/kgx"
if PATH="$TMP/bin-fail:$PATH" WAYLAND_DISPLAY='wayland-1' "$ROOT/onsite.sh" \
   --usb-monitor --usb-terminal kgx --usb-samples 1 --output "$TMP/failed" >"$TMP/failed-output" 2>&1; then
   echo 'FAIL: falso sucesso quando kgx falhou' >&2; exit 1
fi
grep -F 'Falha: o monitor USB não confirmou abertura' "$TMP/failed-output" >/dev/null
grep -F 'ERRO SIMULADO DO KGX' "$TMP/failed-output" >/dev/null
printf 'OK: kgx via -- bash (sem --command), args protegidos, relatorios e falhas detectadas.\n'
