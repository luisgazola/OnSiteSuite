#!/usr/bin/env bash
# Caso de uso de impressão: controle de lote e composição de comprovantes.
ons_print_receipt() {
 local number="$1" count="$2" brand="$3" model="$4" developer="$5" company="$6"
 cat <<EOF2
========================================
OnSiteSuite
Equipamento: Impressora
Marca: $brand
Modelo: $model
Quantidade de impressões de teste: $count

Impressão Número: $number

Lorem ipsum dolor sit amet, consectetur
adipiscing elit. Sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua.

Desenvolvedor: $developer
Empresa: $company

----------------------------------------
----------------------------------------
EOF2
}
ons_escpos_clean() {
 # Translitera para ASCII seguro, sem controles ESC em campos livres.
 if command -v iconv >/dev/null 2>&1; then
   iconv -c -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | LC_ALL=C tr -cd '\11\12\15\40-\176'
 else
   LC_ALL=C tr -cd '\11\12\15\40-\176'
 fi
}
ons_run_print_batch() {
 local queue="$1" count="$2" brand="$3" model="$4" raw="$5" cut="$6" cut_mode="$7" version="$8" tmp="$9" results="${10}" submit="${11}"
 local i output submitted=0 failures=0 evidence='' status summary
 local current CURRENT_TEST='print_batch' CURRENT_TITLE='Sequência avançada de impressão'
 (( count>=1 && count<=100 )) || { printf 'Quantidade fora do intervalo permitido.\n' >&2; return 2; }
 local file="$tmp/ons-print.txt" rawfile="$tmp/ons-escpos.bin"
 brand="$(printf '%s' "$brand" | tr '\n\r\t' '   ' | head -c 100)"
 model="$(printf '%s' "$model" | tr '\n\r\t' '   ' | head -c 100)"
 : > "$file"; : > "$rawfile"
 if ! command -v lp >/dev/null 2>&1; then
   make_result 'NAO_SUPORTADO' 'Cliente CUPS lp ausente' '' 'Instale o cliente CUPS e configure a fila.' >> "$results"; return
 fi
 for ((i=1; i<=count; i++)); do
   current="$(ons_print_receipt "$i" "$count" "$brand" "$model" 'Luís Gazola' 'Excelsior Soluções em Tecnologia')"
   printf '%s\n\n' "$current" >> "$file"
   if [[ "$raw" == 1 ]]; then
     printf '%s\n' "$current" | ons_escpos_clean >> "$rawfile"
     # Alimentação de papel para posicionar o corte, seguida do comando ESC/POS GS V.
     printf '\n\n\n' >> "$rawfile"
     if [[ "$cut" == 1 ]]; then
       if [[ "$cut_mode" == 'partial' ]]; then printf '\035\126\001' >> "$rawfile"; else printf '\035\126\000' >> "$rawfile"; fi
     fi
   else
     printf '%s\n\n' "$current" > "$tmp/print-$i.txt"
   fi
 done
 if [[ "$raw" == 1 ]]; then
   if output="$("$submit" "$queue" "$rawfile" 1 2>&1)"; then
     submitted="$count"; evidence="Lote RAW ESC/POS com $count comprovantes entregue à fila: $output"
   else failures="$count"; evidence="Falha no envio RAW ESC/POS: $output"; fi
 else
   for ((i=1; i<=count; i++)); do
     if output="$("$submit" "$queue" "$tmp/print-$i.txt" 0 2>&1)"; then
       submitted=$((submitted+1)); evidence+="Comprovante $i: $output"$'\n'
     else
       failures=$((failures+1)); evidence+="Falha no comprovante $i: $output"$'\n'
     fi
   done
 fi
 status='INCONCLUSIVO'; ((failures>0)) && status='ATENCAO'
 summary="Fila $queue: $submitted de $count comprovante(s) aceitos pelo spooler; $failures falha(s) de envio. Corte solicitado: $cut."
 evidence+="\nMarca: $brand; Modelo: $model; modo RAW ESC/POS: $raw; modo do corte: $cut_mode. O envio não confirma a impressão ou corte físicos."
 make_result "$status" "$summary" "$evidence" 'Verifique visualmente impressão, alimentação e corte após a execução; compare cabo/porta e configuração da fila se falhar.' >> "$results"
 # O texto enviado é guardado como evidência acessível, sem bytes de controle.
}
