# Adapter de diagnóstico Windows: CIM, cmdlets de inventário e serviços legados.
# Converte cada resultado para o contrato de domínio; não contém UI nem persistência.
function Invoke-OnsWindowsProbe {
 param([string]$Id,[string]$Title,[bool]$Online,[bool]$NonInteractive,[string]$Symptom,[string]$RootPath,[scriptblock]$ChecklistPrompt)
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
    $answers = @(& $ChecklistPrompt $items)
    $failures = @($answers | Where-Object { $_.Resultado -eq 'N' }).Count
    $st=if ($failures -gt 0) {'ATENCAO'} else {'OK'}
    return (New-OnsWindowsResult $Id $Title $st 'Checklist preenchido pelo técnico' $answers)
   }
   default {return (New-OnsWindowsResult $Id $Title 'NAO_SUPORTADO' 'Teste indisponível' '')}
  }
 } catch {
  return (New-OnsWindowsResult $Id $Title 'INCONCLUSIVO' "Falha na coleta: $($_.Exception.Message)" '')
 }
}
