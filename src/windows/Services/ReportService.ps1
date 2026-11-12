# Service Layer de persistência; recebe objetos prontos, não coleta hardware nem escreve no terminal.
function Convert-OnsHtml([object]$Value) {
  return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}
function Write-OnsWindowsReport {
 param([object]$Session,[object[]]$Results)
 $RootPath = $Session.RootPath
 $Output = $Session.Output
 $Client = $Session.Client
 $Ticket = $Session.Ticket
 $Technician = $Session.Technician
 $Serial = $Session.Serial
 $Online = $Session.Online
 $equipment = $Session.Equipment
 $version = $Session.Version
 $rootReport=if ($Output) {$Output} else {Join-Path $RootPath 'Reports'}
 $stamp=(Get-Date).ToUniversalTime()
 $safeTicket=if ($Ticket) {($Ticket -replace '[^A-Za-z0-9_-]','_')} else {'sem-os'}
 if ($safeTicket.Length -gt 35) {$safeTicket=$safeTicket.Substring(0,35)}
 $folder=Join-Path $rootReport ($stamp.ToString('yyyy/MM/dd')+'/'+$safeTicket+'-'+$stamp.ToString('HHmmss')+'-'+[guid]::NewGuid().ToString('N').Substring(0,6))
 $null=New-Item -ItemType Directory -Path $folder -Force

 $payload=[ordered]@{
  schemaVersion='2.0';product='OnSiteSuite';version=$version;createdAt=$stamp.ToString('yyyy-MM-ddTHH:mm:ssZ')
  platform='windows';host=$env:COMPUTERNAME;equipamento=$equipment;onlineChecksAuthorized=$Online
  atendimento=[ordered]@{cliente=$Client;chamado=$Ticket;tecnico=$Technician;serial=$Serial}
  tests=@($results)
  summary=[ordered]@{
   total=$results.Count; ok=@($results|Where-Object {$_.status -eq 'OK'}).Count
   atencao=@($results|Where-Object {$_.status -eq 'ATENCAO'}).Count
   falha=@($results|Where-Object {$_.status -eq 'FALHA'}).Count
   inconclusivo=@($results|Where-Object {$_.status -eq 'INCONCLUSIVO'}).Count
   naoSuportado=@($results|Where-Object {$_.status -eq 'NAO_SUPORTADO'}).Count
  }
  disclaimer='Diagnóstico auxiliar; confirme resultados com o equipamento e procedimento técnico.'
 }
 $jsonPath=Join-Path $folder 'relatorio.json'
 $payload | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
 $lines=New-Object System.Collections.Generic.List[string]
 $lines.Add("OnSiteSuite $version — Laudo $($payload.createdAt)")
 $lines.Add("Excelsior Soluções em Tecnologia | Identificação do equipamento")
 $lines.Add("SO: $($equipment.sistemaOperacional) | Marca: $($equipment.marca) | Modelo: $($equipment.modelo)")
 $lines.Add("Número de série: $($equipment.numeroSerie) | Service Tag: $($equipment.serviceTag) | Tipo: $($equipment.tipo)")
 $lines.Add("CPU: $($equipment.processador) | RAM: $($equipment.memoria) | Armazenamento: $($equipment.armazenamento)")
 $lines.Add("Cliente: $Client | Chamado: $Ticket | Técnico: $Technician")
 foreach ($item in $results) {
  $lines.Add("`n[$($item.status)] $($item.title)")
  $lines.Add($item.summary)
  $lines.Add($item.evidence.details)
  if ($item.recommendations.Count) {$lines.Add('Recomendações: '+($item.recommendations -join '; '))}
 }
 $lines | Set-Content -LiteralPath (Join-Path $folder 'relatorio.txt') -Encoding UTF8
 $style='body{font-family:system-ui,Arial;margin:30px;max-width:1100px;background:#111827;color:#e5e7eb}section,header{background:#1e293b;border:1px solid #475569;border-radius:12px;padding:18px;margin-bottom:14px;overflow-wrap:anywhere}pre{white-space:pre-wrap;word-break:break-word}.OK{color:#86efac}.ATENCAO{color:#fde68a}.INCONCLUSIVO,.NAO_SUPORTADO{color:#cbd5e1}.FALHA{color:#fca5a5}@media print{body,section,header{background:white;color:black}}'
 $html=New-Object System.Collections.Generic.List[string]
 $html.Add('<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OnSiteSuite</title><style>'+$style+'</style></head><body>')
 $html.Add('<header><h1>OnSiteSuite v'+(Convert-OnsHtml $version)+'</h1><p>Excelsior Soluções em Tecnologia · Data UTC: '+(Convert-OnsHtml $payload.createdAt)+'</p><p>Sistema: '+(Convert-OnsHtml $equipment.sistemaOperacional)+' · Marca/Modelo: '+(Convert-OnsHtml $equipment.marca)+' / '+(Convert-OnsHtml $equipment.modelo)+'<br>Serial: '+(Convert-OnsHtml $equipment.numeroSerie)+' · Service Tag: '+(Convert-OnsHtml $equipment.serviceTag)+' · Tipo: '+(Convert-OnsHtml $equipment.tipo)+'<br>CPU: '+(Convert-OnsHtml $equipment.processador)+' · RAM: '+(Convert-OnsHtml $equipment.memoria)+' · Discos: '+(Convert-OnsHtml $equipment.armazenamento)+'</p><p>Cliente: '+(Convert-OnsHtml $Client)+' · Chamado: '+(Convert-OnsHtml $Ticket)+' · Técnico: '+(Convert-OnsHtml $Technician)+'</p></header>')
 foreach ($item in $results) {
   $recommendation=Convert-OnsHtml ($item.recommendations -join '; ')
   $html.Add('<section><h2>'+(Convert-OnsHtml $item.title)+'</h2><b class="'+$item.status+'">'+$item.status+'</b><p>'+(Convert-OnsHtml $item.summary)+'</p><pre>'+(Convert-OnsHtml $item.evidence.details)+'</pre><p>Orientação: '+$recommendation+'</p></section>')
 }
 $html.Add('<footer>Resultados auxiliares; confirmar em campo.</footer></body></html>')
 $html | Set-Content -LiteralPath (Join-Path $folder 'relatorio.html') -Encoding UTF8
 return [pscustomobject]@{Folder=$folder;Summary=$payload.summary}
}
