<#
.SYNOPSIS
    OnSiteSuite v2.0.2 - Diagnóstico de Field Service para Windows.
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
 [switch]$NonInteractive
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'src/windows/Runner.ps1')
$dependencies = New-OnsWindowsDependencies
Start-OnsWindows -Dependencies $dependencies -RootPath $PSScriptRoot -Tests $Tests -All:$All -ListTests:$ListTests -InfoOnly:$InfoOnly -ShowInfo:$ShowInfo -Online:$Online -Client $Client -Ticket $Ticket -Technician $Technician -Serial $Serial -Symptom $Symptom -Output $Output -NonInteractive:$NonInteractive
