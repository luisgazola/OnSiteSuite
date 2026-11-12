# Hardware adapter: Windows printing (text spooler and RAW ESC/POS with opt-in).
function Send-OnsWindowsPrint {
 param([string]$Queue,[string]$Text,[byte[]]$RawData,[bool]$Raw,[string]$RootPath)
 if ($Raw) {
   if (-not ('OnSiteSuite.Printer.RawSpooler' -as [type])) {
     $source = Get-Content -LiteralPath (Join-Path $RootPath 'src/windows/Adapters/WinSpoolRaw.cs') -Raw -Encoding UTF8
     Add-Type -TypeDefinition $source -Language CSharp -ErrorAction Stop
   }
   $job=[OnSiteSuite.Printer.RawSpooler]::Send($Queue,$RawData)
   return "Job RAW registrado pelo WinSpool: $job"
 }
 if (-not (Get-Command Out-Printer -ErrorAction SilentlyContinue)) { throw 'Out-Printer não disponível.' }
 $Text | Out-Printer -Name $Queue -ErrorAction Stop
 return 'Conteúdo enviado ao spooler Windows (impressão física não confirmada).'
}
