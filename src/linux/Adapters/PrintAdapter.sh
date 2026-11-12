#!/usr/bin/env bash
# Saída física explicitamente autorizada via spooler CUPS, sem execução de shell externo.
ons_submit_print_job() { local queue="$1" file="$2" raw="$3"; if [[ "$raw" == 1 ]]; then lp -d "$queue" -o raw -t 'OnSiteSuite ESC/POS' -- "$file"; else lp -d "$queue" -t 'OnSiteSuite Teste' -- "$file"; fi; }
