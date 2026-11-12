# Limpeza arquitetural — v2.0.3

## O que permanece ativo

- `onsite.sh` / `OnSiteSuite.ps1`, `src/linux/`, `src/windows/`
- `config/tests.json`, `config/report.schema.json`, `config/troubleshooting-flows.json`
- `tests/`, `docs/`, `SECURITY.md`, `LICENSE`, `CHANGELOG.md` e `CONTRIBUTING.md`

## O que foi removido da distribuição

1. `src/Controllers`, `src/Core`, `src/Helpers`, `src/Models`, `src/RulesEngine`, `src/Services`, `src/Validators`, `src/Views`: árvores PowerShell antigas, substituídas pela implementação 2.x.
2. `Config/` e `KnowledgeBase/`: arquivos duplicados/desvinculados da execução. **Exceção**: `Config/TroubleshootingFlows.json` foi transferido integralmente para `config/troubleshooting-flows.json` e ambas as plataformas foram atualizadas.
3. `src/windows/Adapters/LegacyPowerShellAdapter.ps1`: importações genéricas antigas substituídas por `WindowsDiagnosticAdapter.ps1`.
4. `Start.ps1`, `src/linux/probes.sh`, `src/linux/equipment.sh`, `src/windows/Equipment.ps1`: shims antigos fora da interface pública suportada. Use `onsite.sh` ou `OnSiteSuite.ps1`.
5. `native/`: coletor C++20 não integrado e redundante à coleta principal.
6. `docs/legacy-fieldservice/` e notas de release antigas: disponíveis nas tags e no histórico Git.

## Garantias e ressalvas

- O contrato JSON permanece `schemaVersion: 2.0`, com `.version: 2.0.3`.
- Mantidos `system`, `cpu`, `memory`, `storage`, `smart`, `battery`, `network`, `usb`, `printer`, `drivers`, `audio`, `display`, `logs`, `security`, `checklist` e `troubleshooting`.
- A remoção de importadores internos pode afetar consumidores externos **não documentados** que utilizavam funções `Get-Fss*` ou `Start.ps1` diretamente. Esses nomes deixam de ser públicos.
- Windows necessita homologação em equipamentos reais antes de afirmar paridade completa. Testes automatizados mockados estão disponíveis.
- Arquivos removidos continuam recuperáveis via Git: `git show v2.0.2:<caminho>`.

## Por que a remoção é preferível a manter código morto?

Menos dependências implícitas, carregamento previsível e menos arquivos para inspecionar e atualizar. A fonte histórica permanece preservada pelo controle de versões, sem exigir código antigo junto de cada distribuição.
