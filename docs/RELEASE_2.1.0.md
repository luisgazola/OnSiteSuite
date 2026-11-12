# OnSiteSuite v2.1.0 — Notas de versão

## Resumo

Esta versão adiciona dois recursos de operação presencial, preservando o MVC + Service Layer introduzido na série 2.0 e o contrato de relatórios JSON `schemaVersion=2.0`.

1. **Monitoramento USB em terminal secundário** com eventos de conexão/desconexão, `\q` para finalizar e salvar o relatório e JSONL completo de eventos. Opção de execução na janela atual para Linux sem GUI.
2. **Impressão de comprovantes numerados** com lotes 1, 3, 5 ou 1–100 unidades, além de suporte opcional a guilhotina ESC/POS RAW após cada comprovante, com confirmação dupla.

## Entregáveis

- `onsite.sh` e `OnSiteSuite.ps1` com novas opções de CLI.
- Services e Adapters isolados em Windows e Linux, sem reintroduzir dependências legadas.
- `comprovante-impressao.txt` e `usb-eventos.jsonl` salvos com laudos JSON/TXT/HTML.
- Testes de regressão Linux, sysfs e impressão mockada, testes PowerShell fornecidos para execução em Windows.
- Script de publicação Git `scripts/publish-github.sh` que preserva histórico e tags antigas.

## Verificações e homologação

- **Linux (software):** regressão e testes simulados aprovados, incluindo comando `\q` com PTY, eventos USB, quantidades e bytes dos comandos `GS V`.
- **Windows:** serviços e adaptadores implementados, sem ambiente de execução PowerShell 7 / hardware Windows para homologar nesta entrega.
- **Impressão física:** não realizada. Não alegar comprovação de qualidade, conectividade elétrica ou corte físico.

## Checklist para homologação em campo

- [ ] Verificar permissão/autorização sobre o equipamento do cliente.
- [ ] Windows: executar `tests/advanced-windows.ps1` no PowerShell 7 e testar monitor `-UsbMonitor`.
- [ ] Linux: iniciar `./onsite.sh --usb-monitor`; conectar/desconectar um dispositivo conhecido; encerrar com `\q` e comparar `usb-eventos.jsonl`.
- [ ] Configurar fila de impressora e imprimir **1** comprovante sem guilhotina; conferir papel e caracteres.
- [ ] Se modelo e driver realmente suportarem RAW ESC/POS, imprimir **1** com guilhotina e confirmação; observar efeito real.
- [ ] Somente após homologar o equipamento, testar lotes 3 e 5, e avaliar ordem e tempo no spooler.
- [ ] Verificar outputs `relatorio.json`, `.txt`, `.html`, e arquivamento com controles LGPD.

## Compatibilidade

- Comandos anteriores de diagnóstico preservados.
- `--print-test FILA --yes-print` continua suportado e agora executa o lote de **1** comprovante por padrão.
- `schemaVersion=2.0` mantido; a identificação da versão passa a `version=2.1.0`.
- Não foi incluído banco, servidor, Docker, dependência Python ou telemetria.

## Atualização de compatibilidade de terminais (sem mudança de versão)

- Linux GNOME: o monitor USB reconhece o **GNOME Console (`kgx`)** com `--usb-terminal kgx` e detecção automática preferencial.
- Windows: entrada `OnSiteSuite.cmd` para Prompt de Comando, com PowerShell 7 como motor obrigatório.
- Parâmetro `-UsbTerminal PowerShell|CMD|Auto` para escolher a janela do monitor, com transporte por `EncodedCommand` e sem interpolação de argumentos em comandos CMD.
- Preservados o número **2.1.0**, o contrato JSON `schemaVersion=2.0`, os relatórios e os comandos de impressão.
- `tests/terminal-linux.sh` acrescentado à suíte; `tests/terminal-windows.ps1` verifica geração de comandos sem hardware. Homologação gráfica física no Windows pendente.

**Publicação:** se a tag `v2.1.0` já existir, o script apenas registra um novo commit em `main`, preservando a tag histórica. Novas instalações clonadas pela tag anterior não recebem esta atualização de compatibilidade automaticamente; use `main` ou um novo release quando apropriado.
