#!/usr/bin/env bash
# Único adaptador que envia um job físico à impressora. Chamado apenas após --yes-print.
ons_submit_print_job() { local queue="$1" file="$2"; lp -d "$queue" -t 'OnSiteSuite Teste' -- "$file"; }
