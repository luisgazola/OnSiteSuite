#!/usr/bin/env bash
# Adaptador de terminais graficos (GNOME Console / kgx e equivalentes).
# Adaptador de inicializacao do terminal grafico; coleta/relatorio seguem no worker.
# A escolha explicita evita fallback silencioso em terminais diferentes do solicitado.
ons_launch_usb_terminal() {
 local root="$1" out="$2" interval="$3" samples="$4" preferred="${5:-auto}" terminal command_line
 local launch_dir launch_ack launch_log launcher_pid started=0 attempt
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
 launch_dir="$(mktemp -d "${TMPDIR:-/tmp}/ons-usb-launch.XXXXXXXX")" || return 2
 chmod 700 "$launch_dir" 2>/dev/null || true
 launch_ack="$launch_dir/started"
 launch_log="$launch_dir/terminal.log"
 args+=(--usb-launch-ack "$launch_ack")
 case "$terminal" in
  kgx)
   # GNOME Console: "--" separa as opções do kgx do programa e seus argumentos.
   # Cada parâmetro segue como argv independente; evita --command e reinterpretação pelo shell.
   kgx -- bash "${args[@]}" >"$launch_log" 2>&1 & ;;
  gnome-terminal)
   gnome-terminal -- bash "${args[@]}" >"$launch_log" 2>&1 & ;;
  konsole)
   konsole -e bash "${args[@]}" >"$launch_log" 2>&1 & ;;
  xfce4-terminal)
   printf -v command_line '%q ' bash "${args[@]}"
   xfce4-terminal --disable-server --command "$command_line" >"$launch_log" 2>&1 & ;;
  xterm)
   xterm -T 'OnSiteSuite - Monitor USB' -e bash "${args[@]}" >"$launch_log" 2>&1 & ;;
 esac
 launcher_pid=$!
 # Um emulador pode retornar 0 mesmo quando o comando filho nunca é iniciado.
 # Só anunciamos sucesso após o serviço USB confirmar que está executando.
 for ((attempt=0; attempt<70; attempt++)); do
  if [[ -f "$launch_ack" ]]; then started=1; break; fi
  if ! kill -0 "$launcher_pid" 2>/dev/null; then
   wait "$launcher_pid" 2>/dev/null || true
   # A aplicação gráfica pode repassar a chamada a uma instância já em execução.
   # Mesmo nesse caso, damos tempo ao processo filho para iniciar.
  fi
  sleep 0.1
 done
 if ((started == 0)); then
  printf 'Falha: o monitor USB não confirmou abertura no terminal %s.\n' "$terminal" >&2
  if [[ -s "$launch_log" ]]; then
   printf 'Erros do terminal:\n' >&2
   sed -n '1,16p' "$launch_log" >&2
  fi
  printf 'Verifique com: %s --version\n' "$terminal" >&2
  printf 'Alternativa: ./onsite.sh --usb-monitor --foreground\n' >&2
  printf 'Arquivo de diagnóstico: %s\n' "$launch_log" >&2
  return 2
 fi
 rm -rf -- "$launch_dir"
 printf 'Monitor USB confirmado via %s. Encerre na nova janela com \q + ENTER.\n' "$terminal"
}
