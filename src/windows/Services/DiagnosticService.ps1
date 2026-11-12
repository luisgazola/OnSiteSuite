# Caso de uso de execução, sem Write-Host e sem salvar arquivos.
function Invoke-OnsDiagnostics {
  param([string[]]$Ids,[object[]]$Catalog,[scriptblock]$Probe,[scriptblock]$Progress,[object]$Options)
  $results = New-Object 'System.Collections.Generic.List[object]'
  foreach ($id in $Ids) {
    $title = [string](@($Catalog | Where-Object { $_.id -eq $id } | Select-Object -First 1)[0].title)
    & $Progress $id $title
    try {
      $result = & $Probe $id $title $Options
      if ($null -eq $result -or $result.id -ne $id -or $result.status -notin @('OK','ATENCAO','FALHA','INCONCLUSIVO','NAO_SUPORTADO')) {
        throw 'O adapter retornou um resultado inválido.'
      }
      $results.Add($result)
    } catch {
      $results.Add((New-OnsWindowsResult -Id $id -Title $title -Status 'INCONCLUSIVO' -Summary 'Falha na execução ou contrato do teste' -Evidence $_.Exception.Message))
    }
  }
  return $results.ToArray()
}
