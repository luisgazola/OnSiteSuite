#!/usr/bin/env bash
# Service Layer: montagem do contrato e persistência em JSON/TXT/HTML.
# Não lê stdin nem imprime menu; o chamador recebe o diretório.
ons_write_reports() {
  local OUT="$1" VERSION="$2" EQUIPMENT_JSON="$3" CLIENT="$4" TICKET="$5" TECHNICIAN="$6" SERIAL="$7" ONLINE="$8" results_file="$9"
  local date_path label folder json
  date_path="$(date -u +%Y/%m/%d)"
  label="$(printf '%s' "${TICKET:-sem-os}" | sed -E 's/[^[:alnum:]_-]+/_/g' | cut -c1-35)"
  [[ -n "$label" ]] || label='sem-os'
  folder="$OUT/$date_path/${label}-$(date -u +%H%M%S)-$$"
  mkdir -p -- "$folder"
  chmod 700 -- "$folder" || true
  json="$folder/relatorio.json"

  jq -n \
   --arg version "$VERSION" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg client "$CLIENT" --arg ticket "$TICKET" --arg technician "$TECHNICIAN" --arg serial "$SERIAL" \
   --arg hostname "$(hostname 2>/dev/null || true)" --arg os 'linux' --argjson online "$ONLINE" \
   --argjson equipment "$EQUIPMENT_JSON" --slurpfile tests "$results_file" '
   {schemaVersion:"2.0",product:"OnSiteSuite",version:$version,createdAt:$timestamp,
    platform:$os,host:$hostname,equipamento:$equipment,onlineChecksAuthorized:($online==1),
    atendimento:{cliente:$client,chamado:$ticket,tecnico:$technician,serial:$serial},
    tests:$tests,
    summary:{total:($tests|length),ok:([$tests[]|select(.status=="OK")]|length),
     atencao:([$tests[]|select(.status=="ATENCAO")]|length),
     falha:([$tests[]|select(.status=="FALHA")]|length),
     inconclusivo:([$tests[]|select(.status=="INCONCLUSIVO")]|length),
     naoSuportado:([$tests[]|select(.status=="NAO_SUPORTADO")]|length)},
    disclaimer:"Resultado diagnóstico auxiliar; não substitui validação física e julgamento profissional."}' > "$json"

  jq -r '
  "OnSiteSuite v\(.version) - Relatório técnico\nData UTC: \(.createdAt)\nHost: \(.host)\nMarca/Modelo: \(.equipamento.marca) / \(.equipamento.modelo)\nSerial: \(.equipamento.numeroSerie) | Service Tag: \(.equipamento.serviceTag)\nTipo: \(.equipamento.tipo)\nCPU/RAM/Discos: \(.equipamento.processador) / \(.equipamento.memoria) / \(.equipamento.armazenamento)\nCliente: \(.atendimento.cliente)\nChamado: \(.atendimento.chamado)\nTécnico: \(.atendimento.tecnico)\n\nResumo: \(.summary | tostring)\n",
  (.tests[] | "\n[\(.status)] \(.title)\n\(.summary)\n\(.evidence.details)\nRecomendações: \(.recommendations|join("; "))")' "$json" > "$folder/relatorio.txt"

  cat > "$folder/relatorio.html" <<'HTML'
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OnSiteSuite - Relatório técnico</title><style>
:root{color-scheme:light dark}*{box-sizing:border-box}body{font:16px/1.55 system-ui,Arial,sans-serif;max-width:1000px;margin:auto;padding:24px;background:#111827;color:#e5e7eb}
h1,h2{color:#f8fafc}section,.hero{border:1px solid #475569;background:#1e293b;padding:18px;border-radius:12px;margin:14px 0;overflow-wrap:anywhere}
small{color:#cbd5e1}.tag{display:inline-block;padding:3px 9px;border-radius:99px;background:#334155;font-weight:700}.OK{color:#86efac}.ATENCAO{color:#fde68a}.FALHA{color:#fca5a5}.INCONCLUSIVO,.NAO_SUPORTADO{color:#cbd5e1}
pre{white-space:pre-wrap;word-break:break-word;overflow-wrap:anywhere;background:#0f172a;border:1px solid #475569;padding:12px;border-radius:8px}footer{margin:22px 0;color:#94a3b8}a{color:#93c5fd}@media print{body{background:white;color:black}h1,h2{color:black}section,.hero,pre{background:white;color:black;border-color:#999}}
</style></head><body>
HTML
  jq -r '"<header class=\"hero\"><h1>OnSiteSuite v\(.version|@html)</h1><p>Excelsior Soluções em Tecnologia · Laudo técnico · \(.createdAt|@html)</p><p>Host: \(.host|@html)<br>Marca: \(.equipamento.marca|@html)<br>Modelo: \(.equipamento.modelo|@html)<br>Número de série: \(.equipamento.numeroSerie|@html)<br>Service Tag: \(.equipamento.serviceTag|@html)<br>Tipo: \(.equipamento.tipo|@html)<br>Processador: \(.equipamento.processador|@html)<br>Memória: \(.equipamento.memoria|@html)<br>Armazenamento: \(.equipamento.armazenamento|@html)<br>Cliente: \(.atendimento.cliente|@html)<br>Chamado: \(.atendimento.chamado|@html)<br>Técnico: \(.atendimento.tecnico|@html)<br>Serial informado: \(.atendimento.serial|@html)</p><p>Testes: \(.summary.total) · OK: \(.summary.ok) · Atenção: \(.summary.atencao) · Inconclusivos: \(.summary.inconclusivo) · Não suportados: \(.summary.naoSuportado)</p></header>"' "$json" >> "$folder/relatorio.html"
  jq -r '.tests[] | "<section><h2>\(.title|@html)</h2><span class=\"tag \(.status)\">\(.status)</span><p>\(.summary|@html)</p><pre>\(.evidence.details|@html)</pre><p><b>Orientação:</b> \((.recommendations|join("; "))|@html)</p></section>"' "$json" >> "$folder/relatorio.html"
  printf '<footer>Resultados auxiliares: confirmar em campo antes de concluir reparos. Relatório local gerado pelo OnSiteSuite %s · Excelsior Soluções em Tecnologia.</footer></body></html>\n' "$VERSION" >> "$folder/relatorio.html"
  chmod 600 -- "$json" "$folder/relatorio.txt" "$folder/relatorio.html" || true
  printf '%s\n' "$folder"
}
