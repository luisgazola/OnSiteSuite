#! /usr/bin/env bash
# Guia de troubleshooting derivado da base de conhecimento; não executa reparos.
probe_troubleshooting() {
  if [[ -z "$SYMPTOM" ]]; then
    make_result "INCONCLUSIVO" "Sintoma não informado (--symptom)" '' 'Use --symptom notebook_lento, sem_internet ou bateria para gerar o fluxo de investigação.'
    return
  fi
  local symptom="$SYMPTOM" steps
  case "$symptom" in
    'notebook lento'|'lentidao'|'lento') symptom='notebook_lento' ;;
    'sem internet'|'wifi'|'rede') symptom='sem_internet' ;;
  esac
  steps="$(jq -r --arg symptom "$symptom" '.[$symptom] // empty | if type=="array" then to_entries | map("\(.key+1). \(.value)") | join("\n") else "" end' "$ROOT_DIR/Config/TroubleshootingFlows.json")"
  if [[ -z "$steps" ]]; then
    make_result "INCONCLUSIVO" "Sintoma sem fluxo específico na base de conhecimento" "Sintoma: $SYMPTOM" 'Defina novo fluxo e revise com o responsável técnico.'
  else
    make_result "INCONCLUSIVO" "Plano orientativo criado para: $symptom (etapas ainda dependem do técnico)" "$steps" 'Registre verificações e resultados reais antes de atribuir causa e reparo.'
  fi
}
