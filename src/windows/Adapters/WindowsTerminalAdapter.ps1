# Lanca monitor USB em uma janela PowerShell 7 ou CMD. Nenhuma logica de diagnostico reside aqui.
function New-OnsWindowsUsbLaunch {
 [CmdletBinding()]
 param([string]$RootPath,[string]$Output,[double]$Interval,[int]$Samples,
       [ValidateSet('Auto','PowerShell','CMD')][string]$Terminal='Auto',[string]$Baseline='')
 if ($Interval -lt 0.2 -or $Interval -gt 60 -or $Samples -lt 0 -or $Samples -gt 100000) {
   throw 'Intervalo / amostras USB invalidos.'
 }
 $selected=$Terminal
 if ($selected -eq 'Auto') {
   if ($env:ONS_USB_TERMINAL -in @('PowerShell','CMD')) {$selected=$env:ONS_USB_TERMINAL}
   else {$selected='PowerShell'}
 }
 $pwsh=Get-Command pwsh.exe -ErrorAction SilentlyContinue
 if (-not $pwsh) {throw 'PowerShell 7 (pwsh.exe) nao encontrado. Instale a versao suportada e adicione ao PATH.'}
 $entry=Join-Path $RootPath 'OnSiteSuite.ps1'
 # EncodedCommand recebe UTF-16LE e evita interpretar caminho/saida como comandos CMD.
 $quotedEntry="'"+$entry.Replace("'","''")+"'"
 $invariant=$Interval.ToString('0.###',[Globalization.CultureInfo]::InvariantCulture)
 $payload="& $quotedEntry -UsbMonitor -UsbMonitorWorker -UsbInterval $invariant -UsbSamples $Samples"
 if ($Output) {$payload+=" -Output '"+$Output.Replace("'","''")+"'"}
 if ($Baseline) {$payload+=" -UsbBaseline '"+$Baseline.Replace("'","''")+"'"}
 $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($payload))
 if ($selected -eq 'CMD') {
   $comspec=if ($env:ComSpec) {$env:ComSpec} else {'cmd.exe'}
   return [pscustomobject]@{Terminal='CMD';FilePath=$comspec;
     ArgumentList="/d /c pwsh.exe -NoLogo -NoProfile -EncodedCommand $encoded";
     EncodedCommand=$encoded}
 }
 return [pscustomobject]@{Terminal='PowerShell';FilePath=$pwsh.Source;
   ArgumentList="-NoLogo -NoProfile -EncodedCommand $encoded";
   EncodedCommand=$encoded}
}
function Start-OnsWindowsUsbMonitorWindow {
 [CmdletBinding()]
 param([string]$RootPath,[string]$Output,[double]$Interval,[int]$Samples,
       [ValidateSet('Auto','PowerShell','CMD')][string]$Terminal='Auto',[string]$Baseline='')
 $invocation=New-OnsWindowsUsbLaunch -RootPath $RootPath -Output $Output -Interval $Interval -Samples $Samples -Terminal $Terminal -Baseline $Baseline
 Start-Process -FilePath $invocation.FilePath -ArgumentList $invocation.ArgumentList -WorkingDirectory $RootPath -ErrorAction Stop | Out-Null
 Write-Host "Monitor USB iniciado em outra janela ($($invocation.Terminal)). Digite \q para encerrar e salvar o relatorio." -ForegroundColor Green
}
