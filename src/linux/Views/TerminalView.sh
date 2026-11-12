#!/usr/bin/env bash
ons_usage() {
cat <<'HELP'
OnSiteSuite 2.0.2 — diagnóstico local Linux | Excelsior Soluções
Uso: ./onsite.sh [opções]
  --list-tests                 Lista códigos de testes disponíveis
  --info                       Exibe identificação do equipamento e sai
  --show-info                  Mostra o painel também em execução não interativa
  --tests system,cpu,storage   Seleciona testes específicos
  --all                        Executa todas as sondagens passivas (exceto checklist)
  --interactive                Abre seleção de testes no terminal
  --online                     Autoriza sondagens de rede externas
  --client NOME                Cliente opcional
  --ticket CODIGO              OS/chamado opcional
  --technician NOME            Técnico opcional
  --serial SERIAL              Serial opcional (não coletado automaticamente)
  --symptom CODIGO             Guia: notebook_lento, sem_internet ou bateria
  --output DIRETORIO           Destino dos relatórios
  --print-test NOME_DA_FILA    Envia página de teste CUPS, somente com --yes-print
  --yes-print                  Confirma explicitamente envio de página de teste
  --quiet                      Mostra apenas caminho do relatório
  --help                       Exibe esta ajuda
Sem opções, abre seleção se houver terminal; em automação executa conjunto padrão.
Nenhuma elevação ou reparo automático. Rede externa exige --online.
HELP
}
ons_select_tests() {
 local current="$1" version="$2" catalog="$3" id title answer mark i
 local -a ids initial
 local -A chosen=()
 mapfile -t ids < <(jq -r '.tests[].id' "$catalog")
 IFS=',' read -r -a initial <<<"$current"
 for id in "${initial[@]}"; do chosen["$id"]=1; done
 while :; do
   printf '\n--- MENU DE TESTES | OnSiteSuite v%s ---\n' "$version"
   for i in "${!ids[@]}"; do
      id="${ids[$i]}"; [[ "${chosen[$id]:-}" == 1 ]] && mark='x' || mark=' '
      title="$(ons_catalog_title "$catalog" "$id")"
      printf '%2d. [%s] %s\n' "$((i+1))" "$mark" "$title"
   done
   printf 'a=Todos os testes passivos | r=Executar | q=Sair\n'
   read -r -p 'Escolha: ' answer || return 10
   case "$answer" in
     r|R) ONS_SELECTED_TESTS=''; for id in "${ids[@]}"; do
             [[ "${chosen[$id]:-}" == 1 ]] && ONS_SELECTED_TESTS+="${ONS_SELECTED_TESTS:+,}$id"
           done
           return 0 ;;
     q|Q) return 10 ;;
     a|A) while IFS= read -r id; do chosen["$id"]=1; done < <(jq -r '.tests[] | select(.kind == "read-only") | .id' "$catalog") ;;
     *) if [[ "$answer" =~ ^[0-9]+$ ]] && ((10#$answer >= 1 && 10#$answer <= ${#ids[@]})); then
          id="${ids[$((10#$answer-1))]}"
          if [[ "${chosen[$id]:-}" == 1 ]]; then unset 'chosen[$id]'; else chosen["$id"]=1; fi
        else printf 'Opção inválida.\n'; fi ;;
   esac
 done
}
ons_progress() { printf '[%s] %s...\n' "$1" "$2"; }
ons_report_saved() {
 local json="$1" folder="$2"
 jq -r '"\nResumo: \(.summary.total) testes; OK=\(.summary.ok); atenção=\(.summary.atencao); inconclusivos=\(.summary.inconclusivo); não suportados=\(.summary.naoSuportado)"' "$json"
 printf 'Relatórios gerados em:\n%s\n' "$folder"
}
