# API interna

Este projeto não expõe API HTTP. A API é composta por funções PowerShell organizadas por camada.

## Controllers

- `Invoke-FssMainController`
- `Invoke-FssAtendimentoController`
- `Invoke-FssDiagnosticController`
- `Invoke-FssTroubleshootingController`

## Services

- `Get-FssInventory`
- `Get-FssStorageInfo`
- `Get-FssBatteryInfo`
- `Get-FssNetworkInfo`
- `Get-FssDriverIssues`
- `New-FssReport`
