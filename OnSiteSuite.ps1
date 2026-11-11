<#
.SYNOPSIS
    OnSiteSuite v2.0.0 - Diagnóstico de Field Service para Windows.
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
Start-OnsWindows -RootPath $PSScriptRoot -Tests $Tests -All:$All -ListTests:$ListTests -Online:$Online -Client $Client -Ticket $Ticket -Technician $Technician -Serial $Serial -Symptom $Symptom -Output $Output -NonInteractive:$NonInteractive
