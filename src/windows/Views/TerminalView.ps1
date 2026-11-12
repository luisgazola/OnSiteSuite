# View: somente apresentação, leitura do terminal e feedback.
function Show-OnsCatalog([object[]]$Catalog) { $Catalog | Format-Table id,title,kind -AutoSize }
function Show-OnsProgress([string]$Id,[string]$Title) { Write-Host "[$Id] $Title" -ForegroundColor Cyan }
function Show-OnsCompleted([object]$Report) {
  Write-Host "`nRelatórios gerados: $($Report.Folder)" -ForegroundColor Green
  Write-Host ($Report.Summary | ConvertTo-Json)
}
function Read-OnsWindowsSelection {
 param([object[]]$Catalog,[string]$Version)
 $chosen = New-Object 'System.Collections.Generic.List[string]'
 foreach ($t in @($Catalog | Where-Object { $_.kind -eq 'read-only' })) { $chosen.Add($t.id) }
 while ($true) {
   Write-Host "`n--- MENU DE TESTES | OnSiteSuite v$Version ---" -ForegroundColor Cyan
   for ($i=0; $i -lt $Catalog.Count; $i++) {
     $t = $Catalog[$i]
     $mark = if ($chosen.Contains($t.id)) { 'x' } else { ' ' }
     Write-Host ('{0,2}. [{1}] {2}' -f ($i+1),$mark,$t.title)
   }
   $answer = (Read-Host 'Número: alternar; R: executar; A: todos passivos; Q: sair').Trim()
   if ($answer -match '^[rR]$') { return [pscustomobject]@{Cancelled=$false;Tests=($chosen.ToArray() -join ',')} }
   if ($answer -match '^[qQ]$') { return [pscustomobject]@{Cancelled=$true;Tests=''} }
   if ($answer -match '^[aA]$') {
     $chosen.Clear()
     foreach ($t in $Catalog) { if ($t.kind -eq 'read-only') { $chosen.Add($t.id) } }
     continue
   }
   $n = 0
   if ([int]::TryParse($answer,[ref]$n) -and $n -ge 1 -and $n -le $Catalog.Count) {
     $id = $Catalog[$n-1].id
     if ($chosen.Contains($id)) { $null = $chosen.Remove($id) } else { $chosen.Add($id) }
   } else { Write-Host 'Opção inválida.' -ForegroundColor Yellow }
 }
}

function Read-OnsWindowsChecklist([string[]]$Items) {
  $answers = New-Object 'System.Collections.Generic.List[object]'
  foreach ($item in $Items) {
    do { $answer = (Read-Host "$item [S/N/NA]").Trim().ToUpperInvariant() } while ($answer -notin @('S','N','NA'))
    $answers.Add([pscustomobject]@{Item=$item;Resultado=$answer})
  }
  return $answers.ToArray()
}
