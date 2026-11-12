#!/usr/bin/env bash
probe_checklist() {
  if [[ ! -t 0 ]]; then make_result 'NAO_SUPORTADO' 'Checklist requer terminal interativo' '' ''; return; fi
  local answers failures=0 line
  if ! answers="$("$ONS_CHECKLIST_PROMPT")"; then
    make_result 'INCONCLUSIVO' 'Checklist interrompido pelo técnico' '' ''
    return
  fi
  while IFS= read -r line; do [[ "$line" == *': n' ]] && failures=$((failures+1)); done <<<"$answers"
  if ((failures)); then
    make_result 'ATENCAO' "$failures item(ns) marcado(s) com falha pelo técnico" "$answers" 'Registrar evidência e ação recomendada para cada falha.'
  else
    make_result 'OK' 'Checklist preenchido (respostas informadas pelo técnico)' "$answers" ''
  fi
}
