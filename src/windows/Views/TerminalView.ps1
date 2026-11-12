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
   $answer = (Read-Host 'Número: alternar; R: executar; A: todos; U: monitor USB; P: imprimir; Q: sair').Trim()
   if ($answer -match '^[rR]$') { return [pscustomobject]@{Cancelled=$false;Action='tests';Tests=($chosen.ToArray() -join ',')} }
   if ($answer -match '^[uU]$') { return [pscustomobject]@{Cancelled=$false;Action='usb';Tests=''} }
   if ($answer -match '^[pP]$') { return [pscustomobject]@{Cancelled=$false;Action='print';Tests=''} }
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

function Read-OnsWindowsPrintOptions {
  Write-Host 'Filas disponíveis:' -ForegroundColor Cyan
  if (Get-Command Get-Printer -ErrorAction SilentlyContinue) {
    Get-Printer -ErrorAction SilentlyContinue | Select-Object Name,DriverName | Format-Table -AutoSize
  }
  $queue=(Read-Host 'Nome da fila (vazio cancela)').Trim()
  if (-not $queue) { return [pscustomobject]@{Cancelled=$true} }
  $text=(Read-Host 'Quantidade [1/3/5 ou 1..100]').Trim()
  $number=0
  if (-not [int]::TryParse($text,[ref]$number) -or $number -lt 1 -or $number -gt 100) {Write-Warning 'Quantidade inválida.';return [pscustomobject]@{Cancelled=$true}}
  $brand=(Read-Host 'Marca (ENTER = não identificado)').Trim()
  $model=(Read-Host 'Modelo (ENTER = não identificado)').Trim()
  if (-not $brand) {$brand='Não identificado'}
  if (-not $model) {$model='Não identificado'}
  $raw=((Read-Host 'Impressora comprovadamente compatível com ESC/POS RAW? [s/N]').Trim() -match '^[sS]$')
  $cut=$false
  if ($raw) { $cut=((Read-Host 'Possui guilhotina ESC/POS? Cortar após cada impressão? [s/N]').Trim() -match '^[sS]$') }
  Write-Warning "Serão enviados $number comprovantes REAIS para $queue. Corte ESC/POS: $cut."
  if ((Read-Host 'Autoriza impressão? Digite SIM') -cne 'SIM') {return [pscustomobject]@{Cancelled=$true}}
  return [pscustomobject]@{Cancelled=$false;Queue=$queue;Count=$number;Brand=$brand;Model=$model;Raw=$raw;Cut=$cut}
}
