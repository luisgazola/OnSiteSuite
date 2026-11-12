# DEPRECATED: legado FieldServiceToolkit. Não é o container do OnSiteSuite v2.0.2.
# A composição real ocorre em src/windows/App/Bootstrap.ps1 (New-OnsWindowsDependencies).
# Mantido para referências históricas de integrações pré-v2.0.
function Get-FssServiceMap {
  [ordered]@{
    Atendimento = 'AtendimentoService'
    Inventory = 'InventoryService'
    Reports = 'ReportService'
    Rules = 'RulesEngineService'
  }
}
