# Execute com PowerShell 7.x em Windows real. Service Layer testado com adapters simulados.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $root 'src/windows/App/Bootstrap.ps1')
$catalog = @(Get-OnsCatalog -RootPath $root)
$ids = @(Resolve-OnsTests -Catalog $catalog -Tests 'system,memory' -All $false)
if ($ids.Count -ne 2) { throw 'Resolve-OnsTests não retornou dois IDs.' }
$probe = {
 param($id,$title,$opt)
 if ($id -eq 'memory') { throw 'Erro simulado' }
 New-OnsWindowsResult -Id $id -Title $title -Status 'OK' -Summary 'Mock' -Evidence '<script>alert(1)</script>'
}
$progress = { param($id,$title) } # UI simulada
$options = [pscustomobject]@{Online=$false;NonInteractive=$true;Symptom='';RootPath=$root}
$results = @(Invoke-OnsDiagnostics -Ids $ids -Catalog $catalog -Probe $probe -Progress $progress -Options $options)
if ($results.Count -ne 2 -or $results[0].status -ne 'OK' -or $results[1].status -ne 'INCONCLUSIVO') {
 throw 'Diagnóstico simulado falhou.'
}
$temporary = Join-Path ([System.IO.Path]::GetTempPath()) ('onsite-test-'+[guid]::NewGuid().ToString('N'))
try {
 $equipment = [pscustomobject]@{
  sistemaOperacional='Windows Teste';numeroSerie='S123';serviceTag='Não identificado';marca='Excelsior'
  modelo='Virtual';tipo='Desktop';processador='Mock';memoria='16 GiB';armazenamento='NVMe virtual'
 }
 $session = [pscustomobject]@{
  RootPath=$root;Output=$temporary;Client='<script>alert(1)</script>';Ticket='CH123';Technician='Teste'
  Serial='';Online=$false;Version='2.1.0';Equipment=$equipment
 }
 $report = Write-OnsWindowsReport -Session $session -Results $results
 $data = Get-Content -Raw -Encoding UTF8 (Join-Path $report.Folder 'relatorio.json') | ConvertFrom-Json
 if ($data.schemaVersion -ne '2.0' -or $data.version -ne '2.1.0' -or $data.summary.total -ne 2) {
  throw 'Contrato JSON Windows inválido.'
 }
 $html = Get-Content -Raw -Encoding UTF8 (Join-Path $report.Folder 'relatorio.html')
 if ($html.Contains('<script>alert(1)</script>') -or -not $html.Contains('&lt;script&gt;')) {
  throw 'O relatório HTML não tratou entrada perigosa.'
 }
 Write-Host 'OK: Windows Services com double, relatório e escape HTML.' -ForegroundColor Green
} finally {
 if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Recurse -Force }
}
