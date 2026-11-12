# OnSiteSuite v2.0.3 — Adaptador de inventário Windows.
# Consultas locais e somente leitura; sem dependência de FieldServiceToolkit/FssState.
# Valores desconhecidos/erros não são convertidos em estado "OK" artificialmente.
function Get-OnsHardwareSnapshot {
  try {
    $cs   = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
    $bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop
    $os   = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $cpu  = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop | Select-Object -First 1
    return [pscustomobject]@{
      Fabricante=$cs.Manufacturer; Modelo=$cs.Model; Serial=$bios.SerialNumber
      Hostname=$env:COMPUTERNAME; SistemaOperacional=$os.Caption; Versao=$os.Version
      BIOS=$bios.SMBIOSBIOSVersion; CPU=$cpu.Name; Nucleos=$cpu.NumberOfCores
      RAM_GB=if ($null -ne $cs.TotalPhysicalMemory) {[math]::Round([double]$cs.TotalPhysicalMemory / 1GB,2)} else {$null}
    }
  } catch { return [pscustomobject]@{Erro=$_.Exception.Message} }
}
function Get-OnsPerformanceSnapshot {
  try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $total = [double]$os.TotalVisibleMemorySize
    $free = [double]$os.FreePhysicalMemory
    $ram = if ($total -gt 0) {[math]::Round((($total - $free) / $total) * 100,2)} else {$null}
    $processors = @(Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop)
    $loads = @($processors | Where-Object {$null -ne $_.LoadPercentage} | ForEach-Object {[double]$_.LoadPercentage})
    $load = if ($loads.Count -gt 0) {[math]::Round([double](($loads | Measure-Object -Average).Average),2)} else {$null}
    return [pscustomobject]@{CpuUsoPercent=$load;RamUsoPercent=$ram;TopProcessos=@(Get-Process -ErrorAction SilentlyContinue | Sort-Object CPU -Descending | Select-Object -First 5 ProcessName,Id,CPU,WorkingSet64)}
  } catch { return [pscustomobject]@{Erro=$_.Exception.Message} }
}
function Get-OnsStorageSnapshot {
  try {
    $volumes = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop | ForEach-Object {
      [pscustomobject]@{
        Unidade=$_.DeviceID
        TamanhoGB=if ($null -ne $_.Size) {[math]::Round([double]$_.Size / 1GB,2)} else {$null}
        LivreGB=if ($null -ne $_.FreeSpace) {[math]::Round([double]$_.FreeSpace / 1GB,2)} else {$null}
        LivrePercent=if ($_.Size -gt 0) {[math]::Round(([double]$_.FreeSpace / [double]$_.Size)*100,2)} else {$null}
      }
    })
    $physical = @()
    if (Get-Command -Name Get-PhysicalDisk -ErrorAction SilentlyContinue) {
      $physical = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
        [pscustomobject]@{
          Nome=$_.FriendlyName;Tipo=$_.MediaType
          TamanhoGB=if ($null -ne $_.Size) {[math]::Round([double]$_.Size / 1GB,2)} else {$null}
          Saude=$_.HealthStatus;OperationalStatus=($_.OperationalStatus -join ',')
        }
      })
    }
    return [pscustomobject]@{Disks=$physical;Volumes=$volumes}
  } catch { return [pscustomobject]@{Erro=$_.Exception.Message} }
}
function Get-OnsBatterySnapshot {
  try {
    $bat = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $bat) { return [pscustomobject]@{Presente=$false;Status='Não coletado';Detalhe='Nenhuma bateria detectada'} }
    return [pscustomobject]@{Presente=$true;CargaPercent=$bat.EstimatedChargeRemaining;AutonomiaMin=$bat.EstimatedRunTime;Status=$bat.BatteryStatus}
  } catch { return [pscustomobject]@{Presente=$false;Erro=$_.Exception.Message} }
}
function Get-OnsDriverIssues {
  try {
    return @(Get-CimInstance -ClassName Win32_PnPEntity -ErrorAction Stop | Where-Object {$null -ne $_.ConfigManagerErrorCode -and $_.ConfigManagerErrorCode -ne 0} | Select-Object Name,DeviceID,ConfigManagerErrorCode,Status)
  } catch { return @([pscustomobject]@{Erro=$_.Exception.Message}) }
}
