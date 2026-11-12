# Composition root PowerShell: constrói dependências reais (scriptblocks), e não string aliases.
. (Join-Path $PSScriptRoot '../Domain/DiagnosticResult.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsDiagnosticAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsProbeAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsEquipmentAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsUsbAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsTerminalAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsPrintAdapter.ps1')
. (Join-Path $PSScriptRoot '../Services/CatalogService.ps1')
. (Join-Path $PSScriptRoot '../Services/DiagnosticService.ps1')
. (Join-Path $PSScriptRoot '../Services/ReportService.ps1')
. (Join-Path $PSScriptRoot '../Services/UsbMonitorService.ps1')
. (Join-Path $PSScriptRoot '../Services/PrintService.ps1')
. (Join-Path $PSScriptRoot '../Views/EquipmentView.ps1')
. (Join-Path $PSScriptRoot '../Views/TerminalView.ps1')
. (Join-Path $PSScriptRoot '../Controllers/SessionController.ps1')
function New-OnsWindowsDependencies {
  return @{
    Equipment = { Get-OnsEquipmentInfo }
    Probe = { param($id,$title,$opt) Invoke-OnsWindowsProbe -Id $id -Title $title -Online $opt.Online -NonInteractive $opt.NonInteractive -Symptom $opt.Symptom -RootPath $opt.RootPath -ChecklistPrompt { param($items) Read-OnsWindowsChecklist -Items $items } }
    Report = { param($session,$results) Write-OnsWindowsReport -Session $session -Results $results }
    Progress = { param($id,$title) Show-OnsProgress -Id $id -Title $title }
    Completed = { param($report) Show-OnsCompleted -Report $report }
    UsbSnapshot = { Get-OnsWindowsUsbSnapshot }
    UsbWindow = {param($root,$out,$interval,$samples,$terminal) Start-OnsWindowsUsbMonitorWindow -RootPath $root -Output $out -Interval $interval -Samples $samples -Terminal $terminal}
    PrintBatch = {param($opt) Invoke-OnsWindowsPrintBatch -Queue $opt.Queue -Count $opt.Count -Brand $opt.Brand -Model $opt.Model -Raw $opt.Raw -Cut $opt.Cut -YesCut $opt.YesCut -YesPrint $opt.YesPrint -CutMode $opt.CutMode -RootPath $opt.RootPath -Submit {param($q,$text,$raw,$israw,$root) Send-OnsWindowsPrint -Queue $q -Text $text -RawData $raw -Raw $israw -RootPath $root} }
  }
}
