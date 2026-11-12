#!/usr/bin/env bash
# Apenas apresentação; nunca coleta hardware.
ons_show_equipment() {
  local data="$1" version="$2" field label value pad
  printf '\n%s\n' '======================================================================'
  printf '  OnSiteSuite v%s | EXCELSIOR SOLUÇÕES\n' "$version"
  printf '  Suíte de diagnóstico, troubleshooting e laudos de Field Service\n'
  printf '  Autoria: Excelsior Soluções em Tecnologia\n'
  printf '  Desenvolvedor: Luís Gazola\n'
  printf '%s\n' '----------------------------------------------------------------------'
  printf '  IDENTIFICAÇÃO DO EQUIPAMENTO (coleta local; sem alterações)\n'
  while IFS=$'\t' read -r label field; do
    value="$(jq -r --arg k "$field" '.[$k] // "Não identificado"' <<<"$data")"
    pad=$((26 - ${#label}))
    ((pad < 1)) && pad=1
    printf '  %s%*s%s\n' "$label" "$pad" '' "$value"
  done <<'FIELDS'
Sistema operacional:	sistemaOperacional
Número de série:	numeroSerie
Service Tag:	serviceTag
Marca:	marca
Modelo:	modelo
Tipo:	tipo
Processador:	processador
Memória RAM:	memoria
Armazenamento:	armazenamento
FIELDS
  printf '%s\n' '----------------------------------------------------------------------'
  printf '  Dados ausentes não são estimados. Confira as etiquetas quando necessário.\n'
  printf '%s\n\n' '======================================================================'
}
