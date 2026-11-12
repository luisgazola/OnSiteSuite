# Relatório de validação — OnSiteSuite v2.1.0

## Implementação

- Linux: monitor USB via sysfs, relatório JSON/TXT/HTML + JSONL, saída por `\q` em PTY; impressão CUPS em lote com opção RAW ESC/POS e corte após cada comprovante.
- Windows: implementação PowerShell 7 de enumeração PnP e encerramento por teclas, spooler Out-Printer e WinSpool RAW P/Invoke C#; testes para executar no ambiente Windows, ainda não homologados.
- Contrato JSON Schema `schemaVersion: 2.0` mantido. Versão do software: `2.1.0`.

## Comandos de validação Linux (sem hardware físico)

```bash
bash tests/run-linux.sh
```

Executa os testes antigos e os novos `usb-monitor-linux.sh` e `printing-linux.sh` com sysfs simulado, `lp` simulado e saída via PTY `\q`.

## Cuidados para homologação Windows

```powershell
pwsh -NoProfile -File ./tests/architecture-windows.ps1
pwsh -NoProfile -File ./tests/adapters-windows.ps1
pwsh -NoProfile -File ./tests/advanced-windows.ps1
```

Validar depois monitoramento com cabo e porta conhecidos, impressora CUPS/Windows real e, **em impressora ESC/POS com guilhotina comprovadamente compatível**, corte de uma impressão antes de aumentar o lote.

## Limites dos resultados

- Teste com spooler simulado confirma bytes e fluxo de chamadas, não impressão/corte físicos.
- O monitor USB registra alterações entre snapshots; não fornece medidas elétricas ou certeza de captura de todos os eventos.
- Testes Windows não foram executados nesta entrega, por ausência de ambiente PowerShell 7/Windows.
