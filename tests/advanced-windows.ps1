# Execute no Windows PowerShell 7.4.6+; nao envia papel nem realiza corte fisico.
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'src/windows/Domain/DiagnosticResult.ps1')
. (Join-Path $root 'src/windows/Services/PrintService.ps1')
. (Join-Path $root 'src/windows/Services/UsbMonitorService.ps1')
$script:lastBytes=@()
$script:submitCalls=0
$submit={ param($q,$text,$bytes,$raw,$path)
  $script:submitCalls++
  $script:lastBytes=$bytes
  if (-not $raw) {throw 'Esperava RAW nos testes de corte.'}
  return 'FAKE-JOB'
}
$result=Invoke-OnsWindowsPrintBatch -Queue 'FAKE' -Count 5 -Brand 'Epson' -Model 'TM-T20' -Raw $true -Cut $true -YesCut $true -YesPrint $true -CutMode 'full' -RootPath $root -Submit $submit
if ($result.Result.id -ne 'print_batch' -or $result.Result.status -ne 'INCONCLUSIVO') { throw 'Contrato de print_batch incorreto.' }
if ($script:submitCalls -ne 1) {throw 'Lote ESC/POS deve gerar somente um job RAW.'}
if ($result.Receipts -notmatch 'Impressão Número: 5') {throw 'Último comprovante ausente.'}
$cuts=0
for($i=0;$i -lt $script:lastBytes.Count-2;$i++) {
 if ($script:lastBytes[$i] -eq 0x1d -and $script:lastBytes[$i+1] -eq 0x56 -and $script:lastBytes[$i+2] -eq 0x00) {$cuts++}
}
if ($cuts -ne 5) {throw "Esperava 5 cortes, encontrados: $cuts"}
$denied=$false
try {Invoke-OnsWindowsPrintBatch -Queue 'FAKE' -Count 2 -Brand '' -Model '' -Raw $true -Cut $true -YesCut $false -YesPrint $true -CutMode full -RootPath $root -Submit $submit | Out-Null} catch {$denied=$true}
if (-not $denied) {throw 'Corte sem confirmação foi aceito.'}
$temp=Join-Path ([IO.Path]::GetTempPath()) ('ons-test-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory -Path $temp -Force
try {
  $report={param($session,$items)
    $dir=Join-Path $temp 'laudo'
    $null=New-Item -ItemType Directory -Path $dir -Force
    ($items|ConvertTo-Json -Depth 8)|Set-Content -LiteralPath (Join-Path $dir 'result.json') -Encoding UTF8
    return [pscustomobject]@{Folder=$dir;Summary=@{total=1}}
  }
  $equipment={return [pscustomobject]@{marca='Teste'}}
  $snapshot={return @{}}
  Invoke-OnsWindowsUsbMonitor -RootPath $root -Output $temp -Interval 0.2 -Samples 1 -Snapshot $snapshot -Report $report -Equipment $equipment
  $logs=@(Get-ChildItem -LiteralPath (Join-Path $temp 'laudo') -Filter 'usb-eventos.jsonl')
  if ($logs.Count -ne 1) {throw 'Relatório USB não foi gravado.'}
} finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host 'OK: Windows PrintService RAW com 5 cortes e UsbMonitor mockado.' -ForegroundColor Green
