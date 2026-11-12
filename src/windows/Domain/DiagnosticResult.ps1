# Model de domínio/DTO compartilhado com contrato report.schema.json.
function New-OnsWindowsResult {
 param([string]$Id,[string]$Title,[ValidateSet('OK','ATENCAO','FALHA','INCONCLUSIVO','NAO_SUPORTADO')][string]$Status,[string]$Summary,[object]$Evidence = $null,[string[]]$Recommendations = @())
 [pscustomobject][ordered]@{
  id=$Id; title=$Title; status=$Status; summary=$Summary
  evidence=[pscustomobject]@{ details=($Evidence | Out-String).Trim() }
  recommendations=@($Recommendations)
  collectedAt=(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
 }
}
