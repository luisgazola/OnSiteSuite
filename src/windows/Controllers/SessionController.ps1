# Controller: apenas orquestra View + serviços, não implementa CIM nem renderiza HTML.
function Start-OnsWindows {
 param([string]$RootPath,[string]$Tests,[bool]$All,[bool]$ListTests,[bool]$Online,
       [string]$Client,[string]$Ticket,[string]$Technician,[string]$Serial,[string]$Symptom,
       [string]$Output,[bool]$NonInteractive,[bool]$InfoOnly,[bool]$ShowInfo,
       [hashtable]$Dependencies)
 $catalog = @(Get-OnsCatalog -RootPath $RootPath)
 if ($ListTests) { Show-OnsCatalog -Catalog $catalog; return }
 $version = (Get-Content -LiteralPath (Join-Path $RootPath 'VERSION') -Raw).Trim()
 $getEquipment = $Dependencies['Equipment']
 $equipment = & $getEquipment
 $showPanel = $InfoOnly -or $ShowInfo -or (-not $NonInteractive -and -not $All -and [string]::IsNullOrWhiteSpace($Tests))
 if ($showPanel) { Show-OnsEquipmentInfo -Info $equipment -Version $version }
 if ($InfoOnly) { return }
 if (-not $All -and [string]::IsNullOrWhiteSpace($Tests) -and -not $NonInteractive) {
   $selection = Read-OnsWindowsSelection -Catalog $catalog -Version $version
   if ($selection.Cancelled) { return }
   $Tests = $selection.Tests
   if ([string]::IsNullOrWhiteSpace($Tests)) { throw 'Nenhum teste selecionado.' }
 }
 $ids = @(Resolve-OnsTests -Catalog $catalog -Tests $Tests -All $All)
 $options = [pscustomobject]@{Online=$Online;NonInteractive=$NonInteractive;Symptom=$Symptom;RootPath=$RootPath}
 $results = @(Invoke-OnsDiagnostics -Ids $ids -Catalog $catalog -Probe $Dependencies.Probe -Progress $Dependencies.Progress -Options $options)
 $session = [pscustomobject]@{
   RootPath=$RootPath;Output=$Output;Version=$version;Equipment=$equipment
   Client=$Client;Ticket=$Ticket;Technician=$Technician;Serial=$Serial;Online=$Online
 }
 $writeReport = $Dependencies['Report']
 $showCompleted = $Dependencies['Completed']
 $report = & $writeReport $session $results
 & $showCompleted $report
}
