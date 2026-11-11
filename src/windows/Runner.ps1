# OnSiteSuite 2.0.1 — Windows adapter. PowerShell 7.6.9 recommended.
# Tests are read-only, there is no automatic elevation, repair, reboot or network call.

function New-OnsWindowsResult {
 param([string]$Id,[string]$Title,[string]$Status,[string]$Summary,[object]$Evidence = $null,[string[]]$Recommendations = @())
 [pscustomobject][ordered]@{
  id=$Id; title=$Title; status=$Status; summary=$Summary
  evidence=[pscustomobject]@{ details=($Evidence | Out-String).Trim() }
  recommendations=@($Recommendations)
  collectedAt=(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
 }
}
function Convert-OnsHtml([string]$Value) { return [System.Net.WebUtility]::HtmlEncode($Value) }
function Initialize-OnsLegacy([string]$RootPath) {
  . (Join-Path $RootPath 'src/Core/Bootstrap.ps1')
  Import-FssLayer (Join-Path $RootPath 'src/Helpers')
  Import-FssLayer (Join-Path $RootPath 'src/Validators')
  Import-FssLayer (Join-Path $RootPath 'src/Models')
  Import-FssLayer (Join-Path $RootPath 'src/Views')
  Import-FssLayer (Join-Path $RootPath 'src/Services')
  Initialize-FssState -RootPath $RootPath
}
function Invoke-OnsWindowsProbe {
 param([string]$Id,[string]$Title,[bool]$Online,[bool]$NonInteractive,[string]$Symptom,[string]$RootPath)
 try {
  switch ($Id) {
   'system' {
    $h=Get-FssHardwareInfo
    if ($h.PSObject.Properties['Erro']) { return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Inventário indisponível' $h) }
    return (New-OnsWindowsResult $Id $Title 'OK' 'Inventário do computador coletado' $h)
   }
   'cpu' {
    $h=Get-FssHardwareInfo; $p=Get-FssPerformanceInfo
    if ($p.PSObject.Properties['Erro']) { return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Métricas de CPU indisponíveis' $p) }
    $summary="CPU: $($h.CPU); uso pontual: $($p.CpuUsoPercent)% (temperatura não medida)"
    $status= if ($null -eq $p.CpuUsoPercent) {'INCONCLUSIVO'} elseif ($p.CpuUsoPercent -ge 90) {'ATENCAO'} else {'OK'}
    return (New-OnsWindowsResult $Id $Title $status $summary $p @('Uso elevado isolado não prova falha de hardware.'))
   }
   'memory' {
    $p=Get-FssPerformanceInfo
    if ($p.PSObject.Properties['Erro']) { return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Memória não analisável' $p) }
    $status=if ($null -eq $p.RamUsoPercent) {'INCONCLUSIVO'} elseif ($p.RamUsoPercent -ge 90) {'ATENCAO'} else {'OK'}
    return (New-OnsWindowsResult $Id $Title $status "Uso pontual de RAM: $($p.RamUsoPercent)% (não é teste de integridade)." $p)
   }
   'storage' {
    $s=Get-FssStorageInfo
    if ($s.PSObject.Properties['Erro']) { return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Inventário de armazenamento indisponível' $s) }
    return (New-OnsWindowsResult $Id $Title 'OK' 'Volumes e discos identificados; saúde física deve ser avaliada à parte' $s)
   }
   'smart' {
    if (-not (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue)) {
      return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Get-PhysicalDisk não disponível neste Windows' '')
    }
    $disks=@(Get-PhysicalDisk -ErrorAction Stop | Select-Object FriendlyName,HealthStatus,OperationalStatus,MediaType,Size)
    if ($disks.Count -eq 0) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Nenhum disco retornado pelo subsistema' '')}
    $bad=@($disks | Where-Object { $_.HealthStatus -ne 'Healthy' })
    $status=if ($bad.Count) {'ATENCAO'} else {'INCONCLUSIVO'}
    return (New-OnsWindowsResult $Id $Title $status 'Estado informado pelo subsistema Windows; não equivale a leitura SMART completa.' $disks @('Verificar atributos SMART com ferramenta compatível do fabricante quando necessário.'))
   }
   'battery' {
    $b=Get-FssBatteryInfo
    if ($b.PSObject.Properties['Erro']) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Bateria não analisável' $b)}
    if (-not $b.Presente) {return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Nenhuma bateria identificada' $b)}
    return (New-OnsWindowsResult $Id $Title 'OK' 'Carga da bateria lida; ciclos e desgaste exigem interfaces adicionais' $b)
   }
   'network' {
    $adapter=@(Get-NetIPConfiguration -ErrorAction Stop | Where-Object { $_.IPv4Address } | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer)
    $extra='Não foram realizadas conexões externas.'
    $state='OK'
    if ($Online) {
      $ping=Test-Connection -TargetName '1.1.1.1' -Count 1 -Quiet -ErrorAction SilentlyContinue
      $dns=$false
      try { $dns=[bool](Resolve-DnsName 'example.com' -ErrorAction Stop | Select-Object -First 1) } catch { $dns=$false }
      $extra="Sondagens externas autorizadas: ICMP=$ping, DNS=$dns (ICMP pode ser bloqueado)."
      if (-not $ping -or -not $dns) {$state='ATENCAO'}
    }
    return (New-OnsWindowsResult $Id $Title $state 'Configurações de rede verificadas' "$(($adapter|Format-List|Out-String))`n$extra" @('Uma falha de ping isolada não prova falta de internet.'))
   }
   'usb' {
    $devices=@(Get-CimInstance Win32_PnPEntity -ErrorAction Stop | Where-Object { $_.PNPDeviceID -like 'USB*' } | Select-Object -First 35 Name,Status,PNPDeviceID)
    if ($devices.Count -eq 0) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Nenhum USB retornado pelo sistema' '')}
    return (New-OnsWindowsResult $Id $Title 'OK' "$($devices.Count) dispositivos USB enumerados; estabilidade física não foi testada" $devices @('Para falha intermitente, comparar porta, cabo, dispositivo e eventos de desconexão.'))
   }
   'printer' {
    $printers=@(Get-CimInstance Win32_Printer -ErrorAction Stop | Select-Object Name,Default,PrinterStatus,PortName,WorkOffline)
    if ($printers.Count -eq 0) {return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Nenhuma impressora cadastrada' '')}
    return (New-OnsWindowsResult $Id $Title 'OK' 'Filas consultadas; impressão e guilhotina não acionadas' $printers)
   }
   'drivers' {
    $issues=@(Get-FssDriverIssues)
    $real=@($issues | Where-Object { $_.DeviceID -or $_.ConfigManagerErrorCode })
    if ($issues.Count -gt 0 -and $null -ne $issues[0] -and $issues[0].PSObject.Properties['Erro']) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Verificação de drivers falhou' $issues)}
    if ($real.Count -gt 0) {return (New-OnsWindowsResult $Id $Title 'ATENCAO' "$($real.Count) dispositivo(s) com erro de configuração" $real)}
    return (New-OnsWindowsResult $Id $Title 'OK' 'Sem erros reportados pelo gerenciador PnP (verificação parcial)' '')
   }
   'audio' {
    $cards=@(Get-CimInstance Win32_SoundDevice -ErrorAction SilentlyContinue | Select-Object Name,Status,Manufacturer)
    if ($cards.Count -eq 0) {return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Sem dispositivo de áudio detectado' '')}
    return (New-OnsWindowsResult $Id $Title 'OK' 'Áudio detectado; reprodução e microfone não testados' $cards)
   }
   'display' {
    $screens=@(Get-CimInstance Win32_DesktopMonitor -ErrorAction SilentlyContinue | Select-Object Name,Status,ScreenHeight,ScreenWidth)
    if ($screens.Count -eq 0) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Monitores não reportados por CIM' '')}
    return (New-OnsWindowsResult $Id $Title 'OK' 'Monitores detectados; inspeção de pixels/brilho deve ser manual' $screens)
   }
   'logs' {
    $since=(Get-Date).AddHours(-24)
    $events=@(Get-WinEvent -FilterHashtable @{LogName='System';Level=2;StartTime=$since} -MaxEvents 25 -ErrorAction SilentlyContinue | Select-Object TimeCreated,Id,ProviderName,Message)
    if ($events.Count -gt 0) {return (New-OnsWindowsResult $Id $Title 'ATENCAO' 'Eventos de erro registrados; correlacione com o sintoma' $events)}
    return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Nenhum evento acessível nas últimas 24h; resultado pode depender de permissões' '')
   }
   'security' {
    $fw=@(Get-NetFirewallProfile -ErrorAction SilentlyContinue | Select-Object Name,Enabled)
    $defender=$null
    if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) { $defender=Get-MpComputerStatus -ErrorAction SilentlyContinue | Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled }
    return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Indicadores parciais de segurança consultados; não é auditoria' ([pscustomobject]@{Firewall=$fw;Defender=$defender}))
   }
   'troubleshooting' {
    if (-not $Symptom) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Sintoma não informado (-Symptom)' '' @('Informe notebook_lento, sem_internet ou bateria.'))}
    $key=$Symptom.Replace(' ','_').ToLowerInvariant()
    if ($key -eq 'lento') {$key='notebook_lento'}
    if ($key -eq 'rede' -or $key -eq 'wifi') {$key='sem_internet'}
    $flows=Get-Content -Raw -Encoding UTF8 (Join-Path $RootPath 'Config/TroubleshootingFlows.json') | ConvertFrom-Json
    $prop=$flows.PSObject.Properties[$key]
    if ($null -eq $prop) {return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' 'Sintoma sem fluxo definido' $Symptom)}
    $steps=@($prop.Value)
    return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' "Plano orientativo: $key (etapas não executadas automaticamente)" ($steps -join "`n") @('Correlacione as etapas com evidências coletadas antes de concluir a causa.'))
   }
   'checklist' {
    if ($NonInteractive) { return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Checklist requer modo interativo' '') }
    $items=@('Equipamento liga normalmente','Fonte/carregador verificado','Tela sem anomalias visuais','Teclado e mouse funcionais','Rede funcional','Áudio confirmado','Impressão, quando aplicável')
    $answers=@(); $failures=0
    foreach ($item in $items) {
      do { $a=(Read-Host "$item [S/N/NA]").Trim().ToUpperInvariant() } while ($a -notin @('S','N','NA'))
      $answers+= [pscustomobject]@{Item=$item;Resultado=$a}
      if ($a -eq 'N') {$failures++}
    }
    $st=if ($failures -gt 0) {'ATENCAO'} else {'OK'}
    return (New-OnsWindowsResult $Id $Title $st 'Checklist preenchido pelo técnico' $answers)
   }
   default {return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Teste indisponível' '')}
  }
 } catch {
  return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' "Falha na coleta: $($_.Exception.Message)" '')
 }
}

function Start-OnsWindows {
 param([string]$RootPath,[string]$Tests,[bool]$All,[bool]$ListTests,[bool]$Online,
       [string]$Client,[string]$Ticket,[string]$Technician,[string]$Serial,[string]$Symptom,[string]$Output,[bool]$NonInteractive,[bool]$InfoOnly,[bool]$ShowInfo)
 $catalog=(Get-Content -Raw -Encoding UTF8 (Join-Path $RootPath 'config/tests.json') | ConvertFrom-Json).tests
 if ($ListTests) { $catalog | Format-Table id,title,kind -AutoSize; return }
 . (Join-Path $RootPath 'src/windows/Equipment.ps1')
 $version=(Get-Content -Raw (Join-Path $RootPath 'VERSION')).Trim()
 $equipment=Get-OnsEquipmentInfo
 if ($InfoOnly -or $ShowInfo -or (-not $NonInteractive -and -not $All -and [string]::IsNullOrWhiteSpace($Tests))) {
  Show-OnsEquipmentInfo -Info $equipment -Version $version
 }
 if ($InfoOnly) { return }
 if ($All) { $Tests=(@($catalog | Where-Object {$_.kind -eq 'read-only'} | ForEach-Object {$_.id}) -join ',') }
 if ([string]::IsNullOrWhiteSpace($Tests) -and -not $NonInteractive) {
  $chosen=New-Object System.Collections.Generic.List[string]
  foreach ($t in @($catalog | Where-Object {$_.kind -eq 'read-only'})) { $chosen.Add($t.id) }
  while ($true) {
   Write-Host "`n--- MENU DE TESTES | OnSiteSuite v2.0.1 ---" -ForegroundColor Cyan
   for ($i=0;$i -lt $catalog.Count;$i++) {
    $t=$catalog[$i]; $x=if ($chosen.Contains($t.id)) {'x'} else {' '}
    Write-Host ('{0,2}. [{1}] {2}' -f ($i+1),$x,$t.title)
   }
   $answer=(Read-Host 'Número: alternar; R: executar; A: todos; Q: sair').Trim()
   if ($answer -match '^[rR]$') { break }
   if ($answer -match '^[qQ]$') { return }
   if ($answer -match '^[aA]$') { $chosen.Clear();foreach ($t in $catalog) {if ($t.kind -eq 'read-only') {$chosen.Add($t.id)}};continue }
   $n=0
   if ([int]::TryParse($answer,[ref]$n) -and $n -ge 1 -and $n -le $catalog.Count) {
    $id=$catalog[$n-1].id
    if ($chosen.Contains($id)) {$null=$chosen.Remove($id)} else {$chosen.Add($id)}
   }
  }
  $Tests=($chosen.ToArray() -join ',')
 }
 if ([string]::IsNullOrWhiteSpace($Tests)) { $Tests='system,cpu,memory,storage,battery,network,usb,printer,drivers,security' }
 $ids=@($Tests.Split(',') | ForEach-Object {$_.Trim()} | Where-Object {$_})
 if ($ids.Count -eq 0) { throw 'Nenhum teste selecionado.' }
 foreach ($id in $ids) { if ($id -notin @($catalog | ForEach-Object {$_.id})) {throw "Teste desconhecido: $id"} }
 Initialize-OnsLegacy $RootPath
 $results=@()
 foreach ($id in $ids) {
  $title=($catalog | Where-Object {$_.id -eq $id} | Select-Object -First 1).title
  Write-Host "[$id] $title" -ForegroundColor Cyan
  $results += (Invoke-OnsWindowsProbe -Id $id -Title $title -Online $Online -NonInteractive $NonInteractive -Symptom $Symptom -RootPath $RootPath)
 }
 $rootReport=if ($Output) {$Output} else {Join-Path $RootPath 'Reports'}
 $stamp=(Get-Date).ToUniversalTime()
 $safeTicket=if ($Ticket) {($Ticket -replace '[^A-Za-z0-9_-]','_')} else {'sem-os'}
 if ($safeTicket.Length -gt 35) {$safeTicket=$safeTicket.Substring(0,35)}
 $folder=Join-Path $rootReport ($stamp.ToString('yyyy/MM/dd')+'/'+$safeTicket+'-'+$stamp.ToString('HHmmss')+'-'+[guid]::NewGuid().ToString('N').Substring(0,6))
 $null=New-Item -ItemType Directory -Path $folder -Force
 $version=(Get-Content -Raw (Join-Path $RootPath 'VERSION')).Trim()
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
 Write-Host "`nRelatórios gerados: $folder" -ForegroundColor Green
 Write-Host ($payload.summary | ConvertTo-Json)
}
