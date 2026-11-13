# Estatísticas de eventos USB enumerados via PnP/CIM. Não inferir qualidade elétrica.
function Get-OnsWindowsUsbAnalysis {
 [CmdletBinding()]
 param([string]$EventsPath,[hashtable]$Initial,[hashtable]$Final,[double]$Interval,[int]$Samples,[string]$Version)
 $devices=@{}
 function New-Record([string]$id,[string]$label,[bool]$initialPresent) {
   $vidPid=''
   if ($id -match '(?i)VID_([A-F0-9]{4})&PID_([A-F0-9]{4})') { $vidPid=($Matches[1]+':'+$Matches[2]).ToLowerInvariant() }
   return [pscustomobject]@{
     key=$id; port=$null; vidPid=$vidPid; label=$label;
     initialPresent=$initialPresent;finalPresent=$false;
     connections=0;disconnections=0;reconnections=0;wasDisconnected=$false;
     firstEvent=$null;lastEvent=$null
   }
 }
 foreach($id in $Initial.Keys) { $devices[[string]$id]=New-Record ([string]$id) ([string]$Initial[$id]) $true }
 $start=$null; $end=$null
 foreach($line in (Get-Content -LiteralPath $EventsPath -Encoding UTF8)) {
   if ([string]::IsNullOrWhiteSpace($line)) {continue}
   $ev=$line|ConvertFrom-Json
   if ($ev.event -eq 'INICIO') {$start=$ev.time;continue}
   if ($ev.event -eq 'FIM') {$end=$ev.time;continue}
   if ($ev.event -notin @('CONECTADO','DESCONECTADO')) {continue}
   $bits=([string]$ev.device) -split ' \| ',2
   $id=[string]$bits[0]
   $label=if ($bits.Count -gt 1) {[string]$bits[1]} else {''}
   if (-not $devices.ContainsKey($id)) {$devices[$id]=New-Record $id $label $false}
   $dev=$devices[$id]
   if (-not $dev.firstEvent) {$dev.firstEvent=$ev.time}
   $dev.lastEvent=$ev.time
   if ($ev.event -eq 'CONECTADO') {
     $dev.connections++
     if ($dev.wasDisconnected) {$dev.reconnections++}
     $dev.wasDisconnected=$false
   } else {
     $dev.disconnections++
     $dev.wasDisconnected=$true
   }
 }
 foreach($id in $Final.Keys) {
   if (-not $devices.ContainsKey([string]$id)) {$devices[[string]$id]=New-Record ([string]$id) ([string]$Final[$id]) $false}
   $devices[[string]$id].finalPresent=$true
 }
 $items=@(foreach($id in ($devices.Keys | Sort-Object)) {
   $d=$devices[$id]
   [ordered]@{key=$d.key;port=$d.port;vidPid=$d.vidPid;label=$d.label;
     initialPresent=$d.initialPresent;finalPresent=$d.finalPresent;
     connections=$d.connections;disconnections=$d.disconnections;reconnections=$d.reconnections;
     firstEvent=$d.firstEvent;lastEvent=$d.lastEvent}
 })
 $connect=0;$disconnect=0;$reconnect=0;$affected=0
 foreach($d in $items) {
  $connect+=$d.connections; $disconnect+=$d.disconnections; $reconnect+=$d.reconnections
  if ($d.connections -gt 0 -or $d.disconnections -gt 0) {$affected++}
 }
 return [ordered]@{
   schemaVersion='1.0';product='OnSiteSuite';version=$Version;
   collectionMethod='windows_cim_pnp_periodic_snapshot';intervalSeconds=$Interval;samples=$Samples;
   startedAt=$start;endedAt=$end;initialDeviceCount=$Initial.Count;finalDeviceCount=$Final.Count;
   metrics=[ordered]@{connections=$connect;disconnections=$disconnect;reconnections=$reconnect;affectedDevices=$affected};
   devices=@($items);
   limitations=@('Amostragem periódica; eventos breves podem ser perdidos.',
     'Os IDs PnP não garantem identificação da porta física.',
     'Reconexões observadas não demonstram defeito elétrico nem identificam a causa.')
 }
}
function Write-OnsWindowsUsbAnalysis {
 [CmdletBinding()]
 param([string]$EventsPath,[hashtable]$Initial,[hashtable]$Final,[double]$Interval,[int]$Samples,[string]$Version,[string]$Destination)
 $data=Get-OnsWindowsUsbAnalysis -EventsPath $EventsPath -Initial $Initial -Final $Final -Interval $Interval -Samples $Samples -Version $Version
 $data|ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Destination -Encoding UTF8
}
function Write-OnsWindowsUsbComparison {
 [CmdletBinding()]
 param([string]$Current,[string]$Baseline,[string]$Destination)
 $c=Get-Content -LiteralPath $Current -Raw -Encoding UTF8 | ConvertFrom-Json
 $p=Get-Content -LiteralPath $Baseline -Raw -Encoding UTF8 | ConvertFrom-Json
 if ($p.product -ne 'OnSiteSuite' -or $p.schemaVersion -ne '1.0' -or $null -eq $p.metrics -or $null -eq $p.devices) {
   throw 'Baseline USB inválido: use usb-resumo.json de uma sessão v2.2.0.'
 }
 $result=[ordered]@{
   schemaVersion='1.0';product='OnSiteSuite';comparisonType='USB_SESSION_DELTA';
   reference=[ordered]@{version=$p.version;startedAt=$p.startedAt;samples=$p.samples;intervalSeconds=$p.intervalSeconds};
   current=[ordered]@{version=$c.version;startedAt=$c.startedAt;samples=$c.samples;intervalSeconds=$c.intervalSeconds};
   delta=[ordered]@{
     connections=([int]$c.metrics.connections-[int]$p.metrics.connections);
     disconnections=([int]$c.metrics.disconnections-[int]$p.metrics.disconnections);
     reconnections=([int]$c.metrics.reconnections-[int]$p.metrics.reconnections)
   };
   observedDeviceKeys=[ordered]@{previous=@($p.devices|ForEach-Object {$_.key});current=@($c.devices|ForEach-Object {$_.key})};
   interpretation='Diferença bruta de contagens. Durações, intervalos e condições diferentes impedem concluir melhora ou piora automaticamente.'
 }
 $result|ConvertTo-Json -Depth 12|Set-Content -LiteralPath $Destination -Encoding UTF8
}
