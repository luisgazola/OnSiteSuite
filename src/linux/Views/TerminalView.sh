#!/usr/bin/env bash
ons_usage() {
cat <<'HELP'
OnSiteSuite 2.2.0 — diagnóstico local Linux | Excelsior Soluções
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
  --print-count N              1, 3, 5 ou número de 1 a 100 (padrão: 1)
  --print-brand MARCA          Marca da impressora (opcional)
  --print-model MODELO         Modelo da impressora (opcional)
  --escpos-raw                 Envio RAW ESC/POS somente para impressora compatível
  --cut-after-each             Comando de guilhotina após cada comprovante (RAW ESC/POS)
  --cut-mode full|partial      Tipo de corte ESC/POS (padrão: full)
  --yes-cut                    Confirma autorização e compatibilidade da guilhotina
  --yes-print                  Confirma explicitamente envio físico de papel
  --usb-monitor                Abre monitor USB contínuo em OUTRO terminal gráfico
  --foreground                 Com --usb-monitor, usa o terminal atual
  --usb-terminal NOME          auto|kgx|gnome-terminal|konsole|xfce4-terminal|xterm
  --usb-interval SEGUNDOS      Intervalo das sondagens (0.2 a 60; padrão 1)
  --usb-samples N              Limita amostras em execução supervisionada / teste
  --usb-baseline ARQUIVO       Compara com usb-resumo.json de sessão anterior
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
   printf 'a=Todos passivos | r=Executar | u=Monitor USB (nova janela) | p=Imprimir recibos | q=Sair\n'
   read -r -p 'Escolha: ' answer || return 10
   case "$answer" in
     u|U) ONS_MENU_ACTION=usb; return 0 ;;
     p|P) ONS_MENU_ACTION=print; return 0 ;;
     r|R) ONS_MENU_ACTION=tests; ONS_SELECTED_TESTS=''; for id in "${ids[@]}"; do
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

# View interativa: mantém perguntas fora dos serviços de impressão.
ons_prompt_print_batch() {
 local queue count mode response raw cut brand model
 command -v lpstat >/dev/null 2>&1 && { printf '\nFilas CUPS disponíveis:\n'; lpstat -a 2>/dev/null || true; }
 read -r -p 'Nome exato da fila CUPS (vazio = cancelar): ' queue || return 1
 [[ -n "$queue" && "$queue" =~ ^[a-zA-Z0-9._-]+$ ]] || { printf 'Fila inválida ou cancelada.\n'; return 1; }
 printf 'Quantidade: [1] uma | [3] três | [5] cinco | [N] personalizada (até 100)\n'
 read -r -p 'Quantidade: ' count || return 1
 [[ "$count" =~ ^[0-9]+$ ]] && ((10#$count >= 1 && 10#$count <= 100)) || { printf 'Quantidade inválida.\n'; return 1; }
 read -r -p 'Marca da impressora (ENTER = Não identificado): ' brand || return 1
 read -r -p 'Modelo da impressora (ENTER = Não identificado): ' model || return 1
 brand="${brand:-Não identificado}"; model="${model:-Não identificado}"
 read -r -p 'Impressora comprovadamente compatível com comandos RAW ESC/POS? [s/N]: ' response || return 1
 raw=0; cut=0
 if [[ "$response" =~ ^[sS]$ ]]; then
   raw=1
   read -r -p 'A impressora possui guilhotina ESC/POS funcional? Testar corte APÓS cada impressão? [s/N]: ' response || return 1
   [[ "$response" =~ ^[sS]$ ]] && cut=1
 fi
 printf '\nATENÇÃO: Serão enviados %s comprovantes reais para %s; corte=%s.\n' "$count" "$queue" "$cut"
 read -r -p 'Autoriza gasto de papel e execução? Digite SIM: ' response || return 1
 [[ "$response" == SIM ]] || { printf 'Cancelado.\n'; return 1; }
 count="$((10#$count))"
 ONS_PRINT_QUEUE="$queue"; ONS_PRINT_COUNT="$count"; ONS_PRINT_BRAND="$brand";
 ONS_PRINT_MODEL="$model"; ONS_PRINT_RAW="$raw"; ONS_PRINT_CUT="$cut"
}
