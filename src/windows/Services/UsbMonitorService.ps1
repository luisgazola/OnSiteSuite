# Monitor de USB, capturas e laudos. Janela secundaria: WindowsTerminalAdapter.ps1.
function Invoke-OnsWindowsUsbMonitor {
 param([string]$RootPath,[string]$Output,[double]$Interval,[int]$Samples,[scriptblock]$Snapshot,[scriptblock]$Report,[scriptblock]$Equipment)
 if ($Interval -lt 0.2 -or $Interval -gt 60 -or $Samples -lt 0 -or $Samples -gt 100000) { throw 'Intervalo ou quantidade de amostras inválida.' }
 $version=(Get-Content -LiteralPath (Join-Path $RootPath 'VERSION') -Raw).Trim()
 $logdir=Join-Path ([IO.Path]::GetTempPath()) ('OnSiteSuite-USB-'+[Guid]::NewGuid().ToString('N'))
 $null=New-Item -ItemType Directory -Path $logdir -Force
 $log=Join-Path $logdir 'usb-eventos.jsonl'
 $prev=& $Snapshot
 $connected=0; $disconnected=0; $sample=0
 $stop=$false; $keys=''
 Write-Host "OnSiteSuite v$version - EXCELSIOR SOLUÇÕES | MONITOR USB" -ForegroundColor Cyan
 Write-Host "Dispositivos iniciais: $($prev.Count) | Intervalo $Interval s"
 Write-Host 'Digite \q para terminar. Para registrar, mantenha esta janela aberta.' -ForegroundColor Yellow
 $append={param($event,$name)
   $record=[ordered]@{time=(Get-Date).ToUniversalTime().ToString('o');event=$event;device=$name}
   ($record|ConvertTo-Json -Compress)| Add-Content -LiteralPath $log -Encoding UTF8
 }
 & $append 'INICIO' "Dispositivos iniciais: $($prev.Count)"
 try {
   while (-not $stop) {
     Start-Sleep -Milliseconds ([int]([Math]::Round($Interval*1000)))
     try {
       while ([Console]::KeyAvailable) {
         $key=[Console]::ReadKey($true).KeyChar
         if ($key -eq [char]13) {continue}
         $keys+=([string]$key)
         if ($keys.Length -gt 2) {$keys=$keys.Substring($keys.Length-2)}
         if ($keys -eq '\q') {$stop=$true;break}
       }
     } catch { if ($Samples -eq 0) {throw 'Terminal interativo indisponível. Use -UsbSamples N para coleta limitada.'} }
     if ($stop) { break }
     $curr=& $Snapshot
     foreach ($id in $curr.Keys) {
       if (-not $prev.ContainsKey($id)) {
         $item="$id | $($curr[$id])"; Write-Host "[$(Get-Date -Format HH:mm:ss)] CONECTADO: $item" -ForegroundColor Green
         & $append 'CONECTADO' $item; $connected++
       }
     }
     foreach ($id in $prev.Keys) {
       if (-not $curr.ContainsKey($id)) {
         $item="$id | $($prev[$id])"; Write-Host "[$(Get-Date -Format HH:mm:ss)] DESCONECTADO: $item" -ForegroundColor Yellow
         & $append 'DESCONECTADO' $item; $disconnected++
       }
     }
     $prev=$curr; $sample++
     if ($Samples -gt 0 -and $sample -ge $Samples) {$stop=$true}
   }
 } finally {
   & $append 'FIM' "Amostras: $sample; conexões: $connected; desconexões: $disconnected"
   $status=if (($connected+$disconnected) -gt 0) {'ATENCAO'} else {'INCONCLUSIVO'}
   $tail=@(Get-Content -LiteralPath $log -Tail 30 -ErrorAction SilentlyContinue)
   $summary="Monitoramento concluído: $sample amostras, $connected conexão(ões) e $disconnected desconexão(ões)."
   $evidence="Monitor por amostragem de ${Interval}s; não detecta eventos que começam e terminam entre as leituras.`n"+($tail -join "`n")
   $result=New-OnsWindowsResult 'usb_monitor' 'Monitoramento contínuo USB' $status $summary $evidence @('Compare cabo, porta e dispositivo quando houver desconexões repetidas.')
   $session=[pscustomobject]@{RootPath=$RootPath;Output=$Output;Version=$version;Equipment=(& $Equipment);Client='';Ticket='';Technician='';Serial='';Online=$false}
   $report=& $Report $session @($result)
   Copy-Item -LiteralPath $log -Destination (Join-Path $report.Folder 'usb-eventos.jsonl') -Force
   Remove-Item -LiteralPath $logdir -Recurse -Force -ErrorAction SilentlyContinue
   Write-Host "Monitor encerrado. Laudos em $($report.Folder)" -ForegroundColor Green
 }
}
