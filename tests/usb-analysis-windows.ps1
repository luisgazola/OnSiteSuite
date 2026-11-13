# Teste determinístico da camada de análise USB, sem usar dispositivos físicos.
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'src/windows/Services/UsbAnalysisService.ps1')
$tmp=Join-Path ([IO.Path]::GetTempPath()) ('ons-usb-analysis-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory -Path $tmp -Force
try {
 $events=Join-Path $tmp 'usb-eventos.jsonl'
 @(
  @{time='2026-01-01T00:00:00Z';event='INICIO';device='Dispositivos iniciais: 1'},
  @{time='2026-01-01T00:00:01Z';event='DESCONECTADO';device='USB\VID_ABCD&PID_1234\SERIAL1 | Impressora USB'},
  @{time='2026-01-01T00:00:02Z';event='CONECTADO';device='USB\VID_ABCD&PID_1234\SERIAL1 | Impressora USB'},
  @{time='2026-01-01T00:00:03Z';event='CONECTADO';device='USB\VID_ABCD&PID_9999\SERIAL2 | Outra impressora'},
  @{time='2026-01-01T00:00:04Z';event='FIM';device='Fim'}
 ) | ForEach-Object {$_|ConvertTo-Json -Compress} |Set-Content -LiteralPath $events -Encoding UTF8
 $initial=@{'USB\VID_ABCD&PID_1234\SERIAL1'='Impressora USB'}
 $final=@{'USB\VID_ABCD&PID_1234\SERIAL1'='Impressora USB';'USB\VID_ABCD&PID_9999\SERIAL2'='Outra impressora'}
 $summary=Join-Path $tmp 'usb-resumo.json'
 Write-OnsWindowsUsbAnalysis -EventsPath $events -Initial $initial -Final $final -Interval 0.5 -Samples 4 -Version '2.2.0' -Destination $summary
 $data=Get-Content -LiteralPath $summary -Raw |ConvertFrom-Json
 if ($data.version -ne '2.2.0' -or $data.metrics.reconnections -ne 1 -or
     $data.metrics.connections -ne 2 -or $data.metrics.disconnections -ne 1 -or
     $data.metrics.affectedDevices -ne 2 -or $data.devices.Count -ne 2) {
   throw 'Contagem dos eventos USB incorreta.'
 }
 $compare=Join-Path $tmp 'usb-comparacao.json'
 Write-OnsWindowsUsbComparison -Current $summary -Baseline $summary -Destination $compare
 $delta=(Get-Content -LiteralPath $compare -Raw |ConvertFrom-Json).delta
 if ($delta.reconnections -ne 0 -or $delta.connections -ne 0 -or $delta.disconnections -ne 0) {
   throw 'Comparação de sessão idêntica deve resultar em delta zero.'
 }
 Write-Host 'OK: Windows USB analytics e comparação determinísticos (mock).' -ForegroundColor Green
} finally {
 Remove-Item -LiteralPath $tmp -Force -Recurse -ErrorAction SilentlyContinue
}
