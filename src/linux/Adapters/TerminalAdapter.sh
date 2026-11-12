#!/usr/bin/env bash
# Adaptador de terminais graficos (GNOME Console / kgx e equivalentes).
# Adaptador de inicializacao do terminal grafico; coleta/relatorio seguem no worker.
# A escolha explicita evita fallback silencioso em terminais diferentes do solicitado.
ons_launch_usb_terminal() {
 local root="$1" out="$2" interval="$3" samples="$4" preferred="${5:-auto}" terminal command_line
 local -a args=("$root/onsite.sh" --usb-monitor --foreground --output "$out" --usb-interval "$interval")
 ((samples>0)) && args+=(--usb-samples "$samples")
 if [[ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
  printf 'Ambiente grafico nao detectado. Use ./onsite.sh --usb-monitor --foreground\n' >&2; return 2
 fi
 case "$preferred" in
  auto)
   for terminal in kgx gnome-terminal konsole xfce4-terminal xterm; do
    command -v "$terminal" >/dev/null 2>&1 && break
   done
   if ! command -v "$terminal" >/dev/null 2>&1; then
    printf 'Terminal grafico ausente: instale kgx (GNOME Console) ou use --foreground.\n' >&2; return 2
   fi ;;
  kgx|gnome-terminal|konsole|xfce4-terminal|xterm)
   terminal="$preferred"
   if ! command -v "$terminal" >/dev/null 2>&1; then
    printf 'Terminal solicitado indisponivel: %s. Instale-o ou use --foreground.\n' "$terminal" >&2; return 2
   fi ;;
  *) printf 'Terminal invalido: %s (auto|kgx|gnome-terminal|konsole|xfce4-terminal|xterm).\n' "$preferred" >&2; return 2 ;;
 esac
 case "$terminal" in
  kgx)
   # kgx --command recebe UMA string; %q protege caminhos e argumentos com espacos/metacaracteres.
   printf -v command_line '%q ' bash "${args[@]}"
   kgx --command "$command_line" >/dev/null 2>&1 & ;;
  gnome-terminal)
   gnome-terminal -- bash "${args[@]}" >/dev/null 2>&1 & ;;
  konsole)
   konsole -e bash "${args[@]}" >/dev/null 2>&1 & ;;
  xfce4-terminal)
   printf -v command_line '%q ' bash "${args[@]}"
   xfce4-terminal --disable-server --command "$command_line" >/dev/null 2>&1 & ;;
  xterm)
   xterm -T 'OnSiteSuite - Monitor USB' -e bash "${args[@]}" >/dev/null 2>&1 & ;;
 esac
 printf 'Monitor USB iniciado via %s. Encerre na nova janela com \q + ENTER.\n' "$terminal"
}
