# Execute com PowerShell 7 no Windows, na pasta do OnSiteSuite.
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$tests=@('architecture-windows.ps1','adapters-windows.ps1','advanced-windows.ps1','terminal-windows.ps1','usb-analysis-windows.ps1')
foreach($test in $tests) {
 Write-Host "Executando $test..." -ForegroundColor Cyan
 & (Join-Path $PSScriptRoot $test)
 if (-not $?) { throw "Falha no teste $test" }
}
Write-Host 'OK: bateria de testes PowerShell. Homologação física ainda é separada.' -ForegroundColor Green
