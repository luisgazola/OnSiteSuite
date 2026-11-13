# Controller: apenas orquestra View + serviços, não implementa CIM nem renderiza HTML.
function Start-OnsWindows {
 param([string]$RootPath,[string]$Tests,[bool]$All,[bool]$ListTests,[bool]$Online,
       [string]$Client,[string]$Ticket,[string]$Technician,[string]$Serial,[string]$Symptom,
       [string]$Output,[bool]$NonInteractive,[bool]$InfoOnly,[bool]$ShowInfo,
       [bool]$UsbMonitor,[bool]$UsbMonitorWorker,[string]$UsbTerminal,[double]$UsbInterval,[int]$UsbSamples,[string]$UsbBaseline,
       [string]$PrintQueue,[int]$PrintCount,[string]$PrintBrand,[string]$PrintModel,
       [bool]$EscPosRaw,[bool]$CutAfterEach,[bool]$YesPrint,[bool]$YesCut,[string]$CutMode,
       [hashtable]$Dependencies)
 if ($UsbInterval -lt 0.2 -or $UsbInterval -gt 60 -or $UsbSamples -lt 0 -or $UsbSamples -gt 100000) { throw 'Intervalo / amostras USB fora do intervalo permitido.' }
 if ($PrintCount -lt 1 -or $PrintCount -gt 100) { throw 'PrintCount deve estar entre 1 e 100.' }
 if ($CutAfterEach -and (-not $EscPosRaw -or -not $YesCut)) { throw 'Corte requer -EscPosRaw -CutAfterEach -YesCut.' }
 if ($CutAfterEach -and (-not $PrintQueue) -and (-not $UsbMonitor)) {throw 'Informe -PrintQueue para testar a guilhotina.'}
 if ($EscPosRaw -and -not $PrintQueue -and -not $UsbMonitor) {throw 'Informe -PrintQueue para ESC/POS.'}
 if ($PrintQueue -and -not $YesPrint) { throw 'Impressão física exige -YesPrint.' }
 if ($UsbBaseline -and -not (Test-Path -LiteralPath $UsbBaseline -PathType Leaf)) {throw 'Arquivo de referência USB não encontrado.'}
 if ($UsbBaseline -and -not $UsbMonitor) {throw 'Use -UsbBaseline apenas com -UsbMonitor.'}
 if ($UsbBaseline) {$UsbBaseline=(Resolve-Path -LiteralPath $UsbBaseline).ProviderPath}
 if ($UsbMonitor) {
   if ($UsbMonitorWorker) {
     Invoke-OnsWindowsUsbMonitor -RootPath $RootPath -Output $Output -Interval $UsbInterval -Samples $UsbSamples -Snapshot $Dependencies.UsbSnapshot -Report $Dependencies.Report -Equipment $Dependencies.Equipment -Baseline $UsbBaseline
   } else { & $Dependencies.UsbWindow $RootPath $Output $UsbInterval $UsbSamples $UsbTerminal $UsbBaseline }
   return
 }
 $catalog = @(Get-OnsCatalog -RootPath $RootPath)
 if ($ListTests) { Show-OnsCatalog -Catalog $catalog; return }
 $version = (Get-Content -LiteralPath (Join-Path $RootPath 'VERSION') -Raw).Trim()
 $getEquipment = $Dependencies['Equipment']
 $equipment = & $getEquipment
 $showPanel = $InfoOnly -or $ShowInfo -or (-not $NonInteractive -and -not $All -and [string]::IsNullOrWhiteSpace($Tests))
 if ($showPanel) { Show-OnsEquipmentInfo -Info $equipment -Version $version }
 if ($InfoOnly) { return }
 if ($PrintQueue -and [string]::IsNullOrWhiteSpace($Tests) -and -not $All) { $Tests='printer' }
 if (-not $All -and [string]::IsNullOrWhiteSpace($Tests) -and -not $NonInteractive) {
   $selection = Read-OnsWindowsSelection -Catalog $catalog -Version $version
   if ($selection.Cancelled) { return }
   if ($selection.Action -eq 'usb') { & $Dependencies.UsbWindow $RootPath $Output $UsbInterval $UsbSamples $UsbTerminal $UsbBaseline; return }
   if ($selection.Action -eq 'print') {
     $chosen=Read-OnsWindowsPrintOptions
     if ($chosen.Cancelled) { return }
     $PrintQueue=$chosen.Queue; $PrintCount=$chosen.Count; $PrintBrand=$chosen.Brand; $PrintModel=$chosen.Model
     $EscPosRaw=$chosen.Raw; $CutAfterEach=$chosen.Cut; $YesCut=$chosen.Cut; $YesPrint=$true
     $Tests='printer'
   } else { $Tests = $selection.Tests }
   if ([string]::IsNullOrWhiteSpace($Tests)) { throw 'Nenhum teste selecionado.' }
 }
 $ids = @(Resolve-OnsTests -Catalog $catalog -Tests $Tests -All $All)
 $options = [pscustomobject]@{Online=$Online;NonInteractive=$NonInteractive;Symptom=$Symptom;RootPath=$RootPath}
 $results = @(Invoke-OnsDiagnostics -Ids $ids -Catalog $catalog -Probe $Dependencies.Probe -Progress $Dependencies.Progress -Options $options)
 $receipt = ''
 if ($PrintQueue) {
   $printOptions=[pscustomobject]@{Queue=$PrintQueue;Count=$PrintCount;Brand=$PrintBrand;Model=$PrintModel;
    Raw=$EscPosRaw;Cut=$CutAfterEach;YesCut=$YesCut;YesPrint=$YesPrint;CutMode=$CutMode;RootPath=$RootPath}
   $batch=& $Dependencies.PrintBatch $printOptions
   $results+=@($batch.Result)
   $receipt=$batch.Receipts
 }
 $session = [pscustomobject]@{
   RootPath=$RootPath;Output=$Output;Version=$version;Equipment=$equipment
   Client=$Client;Ticket=$Ticket;Technician=$Technician;Serial=$Serial;Online=$Online
 }
 $writeReport = $Dependencies['Report']
 $showCompleted = $Dependencies['Completed']
 $report = & $writeReport $session $results
 if ($PrintQueue -and $receipt) {
   Set-Content -LiteralPath (Join-Path $report.Folder 'comprovante-impressao.txt') -Value $receipt -Encoding UTF8
 }
 & $showCompleted $report
}
