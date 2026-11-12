#!/usr/bin/env bash
# Contrato canônico de resultado; CURRENT_TEST e CURRENT_TITLE são locais à invocação
# ons_run_one_probe (escopo dinâmico do Bash), nunca estado persistente/global.
make_result() {
  local status="${1:-INCONCLUSIVO}" summary="${2:-}" evidence="${3:-}" recommendation="${4:-}"
  case "$status" in
    OK|ATENCAO|FALHA|INCONCLUSIVO|NAO_SUPORTADO) ;;
    *) status='INCONCLUSIVO' ;;
  esac
  jq -cn --arg id "$CURRENT_TEST" --arg title "$CURRENT_TITLE" \
    --arg status "$status" --arg summary "$summary" --arg evidence "$evidence" \
    --arg recommendation "$recommendation" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
  {id:$id,title:$title,status:$status,summary:$summary,
   evidence:{details:$evidence},recommendations:(if $recommendation=="" then [] else [$recommendation] end),
   collectedAt:$timestamp}'
}
ons_result_valid() {
  local path="$1" expected_id="$2"
  jq -e --arg id "$expected_id" '
   .id==$id and (.title|type=="string") and
   (.status|IN("OK","ATENCAO","FALHA","INCONCLUSIVO","NAO_SUPORTADO")) and
   (.summary|type=="string") and (.evidence.details|type=="string") and
   (.recommendations|type=="array") and (.collectedAt|type=="string")
   ' "$path" >/dev/null 2>&1
}
