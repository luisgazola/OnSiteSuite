<#
.SYNOPSIS
    OnSiteSuite v2.1.0 - Diagnóstico de Field Service para Windows.
.DESCRIPTION
    Usa os serviços migrados de FieldServiceSuite 1.2.0. OS opcional.
.EXAMPLE
    .\OnSiteSuite.ps1 -ListTests
.EXAMPLE
    .\OnSiteSuite.ps1 -Tests system,cpu,memory,storage,battery,usb -Ticket CH12345
#>
[CmdletBinding()]
param(
 [string]$Tests = '',
 [switch]$All,
 [switch]$ListTests,
 [switch]$InfoOnly,
 [switch]$ShowInfo,
 [switch]$Online,
 [string]$Client = '',
 [string]$Ticket = '',
 [string]$Technician = '',
 [string]$Serial = '',
 [string]$Symptom = '',
 [string]$Output = '',
 [switch]$NonInteractive,
 [switch]$UsbMonitor,
 [switch]$UsbMonitorWorker,
 [ValidateSet('Auto','PowerShell','CMD')][string]$UsbTerminal = 'Auto',
 [double]$UsbInterval = 1,
 [int]$UsbSamples = 0,
 [string]$PrintQueue = '',
 [int]$PrintCount = 1,
 [string]$PrintBrand = 'Não identificado',
 [string]$PrintModel = 'Não identificado',
 [switch]$EscPosRaw,
 [switch]$CutAfterEach,
 [ValidateSet('full','partial')][string]$CutMode = 'full',
 [switch]$YesPrint,
 [switch]$YesCut
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'src/windows/Runner.ps1')
$dependencies = New-OnsWindowsDependencies
Start-OnsWindows -Dependencies $dependencies -RootPath $PSScriptRoot -Tests $Tests -All:$All -ListTests:$ListTests -InfoOnly:$InfoOnly -ShowInfo:$ShowInfo -Online:$Online -Client $Client -Ticket $Ticket -Technician $Technician -Serial $Serial -Symptom $Symptom -Output $Output -NonInteractive:$NonInteractive -UsbMonitor:$UsbMonitor -UsbMonitorWorker:$UsbMonitorWorker -UsbTerminal $UsbTerminal -UsbInterval $UsbInterval -UsbSamples $UsbSamples -PrintQueue $PrintQueue -PrintCount $PrintCount -PrintBrand $PrintBrand -PrintModel $PrintModel -EscPosRaw:$EscPosRaw -CutAfterEach:$CutAfterEach -CutMode $CutMode -YesPrint:$YesPrint -YesCut:$YesCut
