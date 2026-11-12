#!/usr/bin/env bash
# Apresentação interativa. Respostas em stdout; perguntas em stderr.
ons_prompt_checklist() {
  local q answer
  local -a questions=('Equipamento liga normalmente' 'Fonte/carregador verificado' 'Tela sem falhas visuais' 'Teclado e mouse funcionais' 'Conectividade testada' 'Áudio testado' 'Impressão testada, quando aplicável')
  for q in "${questions[@]}"; do
    while :; do
      printf '%s [s/n/na]: ' "$q" >&2
      read -r answer || return 10
      [[ "$answer" =~ ^(s|n|na)$ ]] && break
    done
    printf '%s: %s\n' "$q" "$answer"
  done
}
