# Testes sem abrir janela nem acessar hardware: verificar argumentos PowerShell 7 / CMD.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $root 'src/windows/Adapters/WindowsTerminalAdapter.ps1')
$specialOutput="C:\Temp\Teste com espaços & 'aspas'"
foreach($terminal in @('PowerShell','CMD')) {
 $launch=New-OnsWindowsUsbLaunch -RootPath $root -Output $specialOutput -Interval 0.5 -Samples 3 -Terminal $terminal
 if ($launch.Terminal -ne $terminal) {throw 'Seleção de terminal incorreta.'}
 $decoded=[Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($launch.EncodedCommand))
 if (-not $decoded.Contains('OnSiteSuite.ps1') -or -not $decoded.Contains('-UsbMonitorWorker')) {throw 'Worker ausente.'}
 if (-not $decoded.Contains('-UsbSamples 3') -or -not $decoded.Contains('-UsbInterval 0.5')) {throw 'Parâmetros perdidos.'}
 if (-not $decoded.Contains("''aspas''")) {throw 'Escape de apóstrofos falhou.'}
 if ($launch.ArgumentList -notmatch [regex]::Escape($launch.EncodedCommand)) {throw 'Argumento codificado ausente.'}
 if ($terminal -eq 'CMD' -and ($launch.FilePath -notmatch 'cmd.exe$' -or $launch.ArgumentList -notmatch '^/d /c pwsh.exe')) {throw 'Host CMD incorreto.'}
}
$old=$env:ONS_USB_TERMINAL
try {
 $env:ONS_USB_TERMINAL='CMD'
 $auto=New-OnsWindowsUsbLaunch -RootPath $root -Output '' -Interval 1 -Samples 0 -Terminal 'Auto'
 if ($auto.Terminal -ne 'CMD') {throw 'OnSiteSuite.cmd deveria escolher CMD.'}
 $manual=New-OnsWindowsUsbLaunch -RootPath $root -Output '' -Interval 1 -Samples 0 -Terminal 'PowerShell'
 if ($manual.Terminal -ne 'PowerShell') {throw 'Opção explicita deve sobrescrever Auto.'}
} finally { $env:ONS_USB_TERMINAL=$old }
Write-Host 'OK: preparação de comandos para PowerShell e CMD, encoding e seleção explícita.' -ForegroundColor Green
