#!/usr/bin/env bash
ons_catalog_list() { jq -r '.tests[] | "\(.id)\t\(.title) [\(.kind)]"' "$1"; }
ons_catalog_passive() { jq -r '[.tests[] | select(.kind=="read-only") | .id] | join(",")' "$1"; }
ons_catalog_title() { jq -r --arg id "$2" '.tests[] | select(.id==$id) | .title' "$1"; }
ons_catalog_validate() {
 local file="$1" ids="$2" id
 [[ -n "$ids" && "$ids" != ','* && "$ids" != *',,'* && "$ids" != *',' ]] || return 2
 local -a selected
 IFS=',' read -r -a selected <<<"$ids"
 ((${#selected[@]} > 0)) || return 2
 for id in "${selected[@]}"; do
   jq -e --arg id "$id" '.tests[] | select(.id==$id)' "$file" >/dev/null || {
     printf 'Teste desconhecido: %s\n' "$id" >&2
     return 2
   }
 done
}
