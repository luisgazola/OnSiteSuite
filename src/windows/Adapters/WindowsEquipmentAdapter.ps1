# OnSiteSuite 2.0.3 — identificação de equipamento via CIM (somente leitura).
# As consultas podem falhar em algumas políticas empresariais: nenhum campo é estimado.
function Get-OnsSafeCim([string]$ClassName) {
  try { return (Get-CimInstance -ClassName $ClassName -ErrorAction Stop | Select-Object -First 1) }
  catch { return $null }
}
function Get-OnsCimValue([object]$Record, [string]$PropertyName) {
  if ($null -eq $Record) { return $null }
  $field = $Record.PSObject.Properties[$PropertyName]
  if ($null -eq $field) { return $null }
  return $field.Value
}
function Convert-OnsDeviceValue([object]$Raw) {
  $value = if ($null -eq $Raw) { '' } else { [string]$Raw }
  $value = ($value -replace '[\x00-\x1F\x7F]', ' ').Trim()
  if ($value.Length -gt 160) { $value = $value.Substring(0, 160) }
  if ([string]::IsNullOrWhiteSpace($value)) { return 'Não identificado' }
  $bad = @('none','unknown','not specified','not available','not applicable','n/a','na','0',
           'default string','to be filled by o.e.m.','to be filled by oem',
           'system serial number','system product name','invalid','no asset tag')
  if ($value.ToLowerInvariant() -in $bad) { return 'Não identificado' }
  return $value
}
function Get-OnsEquipmentInfo {
  $osInfo  = Get-OnsSafeCim 'Win32_OperatingSystem'
  $system  = Get-OnsSafeCim 'Win32_ComputerSystem'
  $product = Get-OnsSafeCim 'Win32_ComputerSystemProduct'
  $bios    = Get-OnsSafeCim 'Win32_BIOS'
  $case    = Get-OnsSafeCim 'Win32_SystemEnclosure'
  $cpuInfo = Get-OnsSafeCim 'Win32_Processor'

  $os = Convert-OnsDeviceValue (Get-OnsCimValue $osInfo 'Caption')
  $brand = Convert-OnsDeviceValue (Get-OnsCimValue $system 'Manufacturer')
  $model = Convert-OnsDeviceValue (Get-OnsCimValue $system 'Model')
  $serial = Convert-OnsDeviceValue (Get-OnsCimValue $product 'IdentifyingNumber')
  if ($serial -eq 'Não identificado') {
    $serial = Convert-OnsDeviceValue (Get-OnsCimValue $bios 'SerialNumber')
  }
  $serviceTag = 'Não identificado'
  if ($brand -match '(?i)dell' -and $serial -ne 'Não identificado') { $serviceTag = $serial }

  $type = 'Não identificado'
  $chassis = @(Get-OnsCimValue $case 'ChassisTypes')
  if ($chassis.Count -gt 0 -and $null -ne $chassis[0]) {
    switch ([int]$chassis[0]) {
      13 { $type = 'AIO (All-in-One)'; break }
      { $_ -in @(8,9,10,11,14,30,31,32) } { $type = 'Notebook'; break }
      { $_ -in @(3,4,5,6,7,15,16) } { $type = 'Desktop'; break }
    }
  }
  if ($type -eq 'Não identificado') {
    $computerType = Get-OnsCimValue $system 'PCSystemType'
    if ($null -ne $computerType) {
      switch ([int]$computerType) { 1 { $type = 'Desktop' } 2 { $type = 'Notebook' } }
    }
  }
  $cpu = Convert-OnsDeviceValue (Get-OnsCimValue $cpuInfo 'Name')
  $ram = 'Não identificado'
  $bytes = Get-OnsCimValue $system 'TotalPhysicalMemory'
  if ($null -ne $bytes -and [double]$bytes -gt 0) {
    $ram = ('{0:N1} GiB' -f ([double]$bytes / 1GB))
  }
  $storage = 'Não identificado'
  try {
    $allDisks = @(Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction Stop | Select-Object -First 4)
    $items = @()
    foreach ($disk in $allDisks) {
      $diskModel = Convert-OnsDeviceValue (Get-OnsCimValue $disk 'Model')
      $sizeBytes = Get-OnsCimValue $disk 'Size'
      $size = if ($sizeBytes -and [double]$sizeBytes -gt 0) { '{0:N0} GiB' -f ([double]$sizeBytes / 1GB) } else { '?' }
      $items += "$diskModel ($size)"
    }
    if ($items.Count -gt 0) { $storage = Convert-OnsDeviceValue ($items -join '; ') }
  } catch { }
  return [pscustomobject][ordered]@{
    sistemaOperacional=$os
    numeroSerie=$serial
    serviceTag=$serviceTag
    marca=$brand
    modelo=$model
    tipo=$type
    processador=$cpu
    memoria=$ram
    armazenamento=$storage
  }
}
