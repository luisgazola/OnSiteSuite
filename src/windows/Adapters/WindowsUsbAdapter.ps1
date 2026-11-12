# Leitura somente, PnP USB enumerado. Não implica avaliação elétrica do barramento.
function Get-OnsWindowsUsbSnapshot {
 $devices=@(Get-CimInstance Win32_PnPEntity -ErrorAction Stop | Where-Object { $_.PNPDeviceID -like 'USB*' })
 $map=@{}
 foreach ($d in $devices) {
   if ($d.PNPDeviceID) {
     $id=[string]$d.PNPDeviceID
     $map[$id]=[string]$d.Name
   }
 }
 return $map
}
