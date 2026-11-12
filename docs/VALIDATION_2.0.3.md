# Validação — OnSiteSuite v2.0.3

## Verificações executadas (Linux)

- Catálogo/JSON e análise sintática Bash: `tests/check-catalog.sh`.
- Identificação de equipamento e dados ausentes: `tests/equipment-linux.sh`.
- Service Layer e resultados inconclusivos com doubles: `tests/architecture-linux.sh`.
- Execução CLI, laudos JSON/TXT/HTML, escape de HTML e impressão não autorizada: `tests/smoke-linux.sh`.
- Contrato JSON Schema 2020-12: `tests/contract-linux.sh`.
- Fluxos de troubleshooting após migração: `tests/troubleshooting-linux.sh`.
- Ausência de diretórios e referências legadas: `tests/cleanup-linux.sh`.

Executar tudo: `bash tests/run-linux.sh`.

## Windows

**Não homologado em Windows real neste ambiente.** As seguintes verificações foram adicionadas para execução futura no PowerShell 7:

```powershell
pwsh -NoProfile -File ./tests/architecture-windows.ps1
pwsh -NoProfile -File ./tests/adapters-windows.ps1
```

O segundo teste substitui CIM por dados simulados: não consulta hardware real, não exige administração e não altera o sistema.

## Restrições

Testes SMART com diferentes controladoras, impressoras físicas, falhas intermitentes USB e sensores OEM dependem de hardware real e permissões. Os laudos representam resultados parciais e não certificam integridade de hardware.
