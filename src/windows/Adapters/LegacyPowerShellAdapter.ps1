# Adapter anti-corruption para Services do antigo FieldServiceToolkit.
function Initialize-OnsLegacy([string]$RootPath) {
  . (Join-Path $RootPath 'src/Core/Bootstrap.ps1')
  Import-FssLayer (Join-Path $RootPath 'src/Helpers')
  Import-FssLayer (Join-Path $RootPath 'src/Validators')
  Import-FssLayer (Join-Path $RootPath 'src/Models')
  Import-FssLayer (Join-Path $RootPath 'src/Views')
  Import-FssLayer (Join-Path $RootPath 'src/Services')
  Initialize-FssState -RootPath $RootPath
}
