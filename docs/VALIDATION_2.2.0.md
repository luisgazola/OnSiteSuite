# Registro de validação — v2.2.0

| Verificação | Resultado | Evidência |
|---|---|---|
| `tests/run-linux.sh` | Aprovado | Testes de regressão Linux, incluindo catálogo, CLI, contrato JSON, relatórios, KGX simulado e impressão simulada |
| `tests/usb-analysis-linux.sh` | Aprovado | Eventos determinísticos; reconexões por dispositivo; baseline de comparação; baseline inválida recusada; integração com monitor |
| Compatibilidade do relatório JSON principal | Aprovado | `schemaVersion=2.0` |
| Teste de unitário PowerShell de análise | Implementado, não executado neste ambiente | `tests/usb-analysis-windows.ps1` |
| Windows real, testes novos 2.2.0 | Pendente | Executar no equipamento homologado pelo responsável |
| Captura USB com hardware real na v2.2.0 | Pendente | Usar pendrive e impressora conhecidos; guardar a saída da sessão |
| Impressão e guilhotina em hardware real | Pendente | Iniciar com 1 comprovante sem corte; depois validar compatibilidade ESC/POS |

A declaração do responsável de que a v2.1.0 funcionou no Windows é registrada como feedback de campo, sem extrapolar a cobertura para novos recursos ou modelos de impressoras.
