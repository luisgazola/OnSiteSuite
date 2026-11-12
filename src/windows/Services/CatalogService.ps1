# Contrato único, independente do terminal.
function Get-OnsCatalog([string]$RootPath) {
  $file = Join-Path $RootPath 'config/tests.json'
  $doc = Get-Content -LiteralPath $file -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
  return @($doc.tests)
}
function Resolve-OnsTests {
  param([object[]]$Catalog,[string]$Tests,[bool]$All)
  if ($All) { $Tests = (@($Catalog | Where-Object { $_.kind -eq 'read-only' } | ForEach-Object { $_.id }) -join ',') }
  if ([string]::IsNullOrWhiteSpace($Tests)) {
    $Tests = 'system,cpu,memory,storage,battery,network,usb,printer,drivers,security'
  }
  $ids = @($Tests.Split(',') | ForEach-Object { $_.Trim() })
  if ($ids.Count -eq 0 -or @($ids | Where-Object { -not $_ }).Count -gt 0) { throw 'Nenhum teste válido selecionado.' }
  $known = @($Catalog | ForEach-Object { $_.id })
  foreach ($id in $ids) { if ($id -notin $known) { throw "Teste desconhecido: $id" } }
  return $ids
}
