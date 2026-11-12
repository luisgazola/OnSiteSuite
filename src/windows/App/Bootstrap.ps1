# Composition root PowerShell: constrói dependências reais (scriptblocks), e não string aliases.
. (Join-Path $PSScriptRoot '../Domain/DiagnosticResult.ps1')
. (Join-Path $PSScriptRoot '../Adapters/LegacyPowerShellAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsProbeAdapter.ps1')
. (Join-Path $PSScriptRoot '../Adapters/WindowsEquipmentAdapter.ps1')
. (Join-Path $PSScriptRoot '../Services/CatalogService.ps1')
. (Join-Path $PSScriptRoot '../Services/DiagnosticService.ps1')
. (Join-Path $PSScriptRoot '../Services/ReportService.ps1')
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
  }
}
