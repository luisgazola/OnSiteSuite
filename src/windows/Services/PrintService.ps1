# Caso de uso avançado: constrói comprovantes e instrui adapter de impressão.
function New-OnsReceipt([int]$Number,[int]$Count,[string]$Brand,[string]$Model) {
 @"
========================================
OnSiteSuite
Equipamento: Impressora
Marca: $Brand
Modelo: $Model
Quantidade de impressões de teste: $Count

Impressão Número: $Number

Lorem ipsum dolor sit amet, consectetur
adipiscing elit. Sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua.

Desenvolvedor: Luís Gazola
Empresa: Excelsior Soluções em Tecnologia

----------------------------------------
----------------------------------------
"@
}
function Invoke-OnsWindowsPrintBatch {
 param([string]$Queue,[int]$Count,[string]$Brand,[string]$Model,[bool]$Raw,[bool]$Cut,[bool]$YesCut,
       [bool]$YesPrint,[string]$CutMode,[string]$RootPath,[scriptblock]$Submit)
 if (-not $YesPrint) { throw 'A impressão física requer -YesPrint.' }
 if ($Count -lt 1 -or $Count -gt 100) { throw 'Quantidade deve estar entre 1 e 100.' }
 if ($Queue -notmatch '^[a-zA-Z0-9._ -]+$') { throw 'Nome da fila de impressão inválido.' }
 if ($Cut -and (-not $Raw -or -not $YesCut)) { throw 'Guilhotina exige -EscPosRaw -CutAfterEach -YesCut.' }
 if ($CutMode -notin @('full','partial')) { throw 'CutMode deve ser full ou partial.' }
 $receipts=New-Object 'System.Collections.Generic.List[string]'
 for ($i=1; $i -le $Count; $i++) { $receipts.Add((New-OnsReceipt $i $Count $Brand $Model)) }
 $text=$receipts -join "`r`n`r`n"
 $accepted=0; $failed=0; $details=New-Object 'System.Collections.Generic.List[string]'
 if ($Raw) {
   $bytes=New-Object 'System.Collections.Generic.List[byte]'
   foreach ($receipt in $receipts) {
     $ascii=($receipt -replace '[^\x20-\x7e\r\n]','?') + "`r`n`r`n`r`n"
     $bytes.AddRange([System.Text.Encoding]::ASCII.GetBytes($ascii))
     if ($Cut) {
       $mode=if ($CutMode -eq 'partial') { [byte]1 } else { [byte]0 }
       $bytes.AddRange([byte[]]@(0x1d,0x56,$mode))
     }
   }
   try { $details.Add([string](& $Submit $Queue $text $bytes.ToArray() $true $RootPath)); $accepted=$Count }
   catch { $details.Add("Falha RAW: $($_.Exception.Message)"); $failed=$Count }
 } else {
   for ($i=0; $i -lt $receipts.Count; $i++) {
     try { $details.Add([string](& $Submit $Queue $receipts[$i] ([byte[]]@()) $false $RootPath)); $accepted++ }
     catch { $details.Add("Falha no comprovante $($i+1): $($_.Exception.Message)"); $failed++ }
   }
 }
 $state=if ($failed -gt 0) {'ATENCAO'} else {'INCONCLUSIVO'}
 $summary="Fila ${Queue}: $accepted de $Count comprovantes aceitos pelo spooler; $failed falhas. Corte solicitado: $Cut."
 $evidence="Marca: $Brand; modelo: $Model; RAW: $Raw; corte: $Cut; modo: $CutMode.`n"+($details -join "`n")
 return [pscustomobject]@{
   Result=(New-OnsWindowsResult 'print_batch' 'Sequência avançada de impressão' $state $summary $evidence @('Verifique a impressão e o corte no equipamento; spooler aceito não confirma resultado físico.'))
   Receipts=$text
 }
}
