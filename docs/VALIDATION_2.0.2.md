# Relatório de validação — OnSiteSuite 2.0.2

## Cenários executados no ambiente Linux

| Teste | Resultado | Escopo |
| --- | --- | --- |
| `tests/check-catalog.sh` | **PASSOU** | Catálogo único, IDs válidos e sintaxe Bash dos módulos |
| `tests/equipment-linux.sh` | **PASSOU** | Classificação de equipamento e dados ausentes/Dell simulados |
| `tests/smoke-linux.sh` | **PASSOU** | Entradas CLI, formatos de laudo, codificação HTML, consentimento de impressão e permissões |
| `tests/architecture-linux.sh` | **PASSOU** | Substituição do adapter por mock, fallback INCONCLUSIVO e serviço de laudos isolado |
| `tests/contract-linux.sh` | **PASSOU** | `schemaVersion: 2.0` e validação JSON Schema 2020-12 |
| CLI interativa simulada em PTY | **PASSOU** | Menu, execução do teste system e geração de relatório |
| Diagnóstico Linux com múltiplos módulos | **PASSOU** | Execução do catálogo de coletores locais e troubleshooting sem `--online` |
| Componente opcional C++20 | **PASSOU** | Compilação CMake e retorno JSON do probe |
| Publicação Git simulada | **PASSOU** | Clone com commit anterior, aplicação da árvore e criação da tag v2.0.2, preservando v2.0.1 |

## Limitações

- **Não houve execução do PowerShell em Windows real.** Os testes `tests/architecture-windows.ps1` e a sondagem física precisam ser validados em Windows 10/11 com PowerShell 7.
- Não foram realizados testes físicos com bateria, impressora térmica, corte de guilhotina, periféricos USB instáveis ou SMART real.
- O teste de publicação utilizou **repositório Git local simulado**, sem qualquer alteração no GitHub oficial.
- A suíte é um apoio ao diagnóstico; resultados pontuais não certificam a integridade do equipamento.
