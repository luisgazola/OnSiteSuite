# Execute no PowerShell 7, preferencialmente em Windows. Não acessa hardware real.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $root 'src/windows/App/Bootstrap.ps1')

# Sobrescreve a interface CIM com um double local para verificar os coletores.
function Get-CimInstance {
  param([string]$ClassName,[string]$Filter,[string]$ErrorAction)
  switch ($ClassName) {
    'Win32_ComputerSystem' { return [pscustomobject]@{Manufacturer='MockCorp';Model='Model 1';TotalPhysicalMemory=17179869184} }
    'Win32_BIOS' { return [pscustomobject]@{SerialNumber='ABC123';SMBIOSBIOSVersion='1.0'} }
    'Win32_OperatingSystem' { return [pscustomobject]@{Caption='Windows Test';Version='10.0';TotalVisibleMemorySize=16000;FreePhysicalMemory=8000} }
    'Win32_Processor' { return [pscustomobject]@{Name='Mock CPU';NumberOfCores=4;LoadPercentage=25} }
    'Win32_LogicalDisk' { return [pscustomobject]@{DeviceID='C:';Size=107374182400;FreeSpace=53687091200} }
    'Win32_Battery' { return [pscustomobject]@{EstimatedChargeRemaining=80;EstimatedRunTime=90;BatteryStatus=2} }
    'Win32_PnPEntity' { return @([pscustomobject]@{Name='OK';DeviceID='A';ConfigManagerErrorCode=0},[pscustomobject]@{Name='Falha';DeviceID='B';ConfigManagerErrorCode=10}) }
    default { throw "Consulta inesperada: $ClassName" }
  }
}
function Get-PhysicalDisk {
  return [pscustomobject]@{FriendlyName='Mock Disk';MediaType='SSD';Size=107374182400;HealthStatus='Healthy';OperationalStatus='OK'}
}
function Get-Process { return @() }

$h = Get-OnsHardwareSnapshot
if ($h.CPU -ne 'Mock CPU' -or $h.Serial -ne 'ABC123' -or $h.RAM_GB -ne 16) {throw 'HardwareAdapter divergiu.'}
$p = Get-OnsPerformanceSnapshot
if ($p.CpuUsoPercent -ne 25 -or $p.RamUsoPercent -ne 50) {throw 'PerformanceAdapter divergiu.'}
$s = Get-OnsStorageSnapshot
if (@($s.Volumes).Count -ne 1 -or $s.Volumes[0].LivrePercent -ne 50) {throw 'StorageAdapter divergiu.'}
$b = Get-OnsBatterySnapshot
if (-not $b.Presente -or $b.CargaPercent -ne 80) {throw 'BatteryAdapter divergiu.'}
$issues = @(Get-OnsDriverIssues)
if ($issues.Count -ne 1 -or $issues[0].ConfigManagerErrorCode -ne 10) {throw 'DriverAdapter divergiu.'}

$diagOptions = [pscustomobject]@{Online=$false;NonInteractive=$true;Symptom='';RootPath=$root}
foreach ($id in @('system','cpu','memory','storage','battery','drivers')) {
  $result = Invoke-OnsWindowsProbe -Id $id -Title $id -Online:$false -NonInteractive:$true -Symptom '' -RootPath $root -ChecklistPrompt { param($items) }
  if ($result.id -ne $id -or $result.status -notin @('OK','ATENCAO','INCONCLUSIVO','NAO_SUPORTADO','FALHA')) {
    throw "Contrato inválido para $id"
  }
}

$flow = Invoke-OnsWindowsProbe -Id 'troubleshooting' -Title 'Troubleshooting' -Online:$false -NonInteractive:$true -Symptom 'sem_internet' -RootPath $root -ChecklistPrompt { param($items) }
if ($flow.status -ne 'INCONCLUSIVO' -or $flow.evidence.details.Length -lt 15) {throw 'Migração do fluxo de troubleshooting falhou.'}
Write-Host 'OK: adaptadores Windows isolados com CIM simulado e contratos preservados.' -ForegroundColor Green
