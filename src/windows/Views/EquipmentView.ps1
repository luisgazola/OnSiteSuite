# Apenas renderização; não faz CIM ou coleta de dados.
function Show-OnsEquipmentInfo([object]$Info, [string]$Version) {
  Write-Host ''
  Write-Host '======================================================================' -ForegroundColor DarkCyan
  Write-Host "  OnSiteSuite v$Version | EXCELSIOR SOLUÇÕES" -ForegroundColor Cyan
  Write-Host '  Suíte de diagnóstico, troubleshooting e laudos de Field Service'
  Write-Host '  Autoria: Excelsior Soluções em Tecnologia'
  Write-Host '  Desenvolvedor: Luís Gazola'
  Write-Host '----------------------------------------------------------------------' -ForegroundColor DarkCyan
  Write-Host '  IDENTIFICAÇÃO DO EQUIPAMENTO (coleta local; sem alterações)'
  $rows = @(
    @('Sistema operacional:', 'sistemaOperacional'),
    @('Número de série:', 'numeroSerie'),
    @('Service Tag:', 'serviceTag'),
    @('Marca:', 'marca'),
    @('Modelo:', 'modelo'),
    @('Tipo:', 'tipo'),
    @('Processador:', 'processador'),
    @('Memória RAM:', 'memoria'),
    @('Armazenamento:', 'armazenamento')
  )
  foreach ($row in $rows) {
    $field = $row[1]
    Write-Host ('  {0,-24} {1}' -f $row[0], $Info.$field)
  }
  Write-Host '----------------------------------------------------------------------' -ForegroundColor DarkCyan
  Write-Host '  Dados ausentes não são estimados. Confira etiquetas quando necessário.'
  Write-Host '======================================================================' -ForegroundColor DarkCyan
  Write-Host ''
}
