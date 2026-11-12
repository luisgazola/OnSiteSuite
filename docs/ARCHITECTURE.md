# Arquitetura — OnSiteSuite v2.1.0

## Objetivo

Aplicativo de diagnóstico local Linux/Windows com arquitetura modular de CLI, inspirado em **MVC + Service Layer**. Não utiliza servidor HTTP, persistência central ou estrutura de framework web.

```text
onsite.sh / OnSiteSuite.ps1       Entradas públicas
             |
       App / Bootstrap            Composição de dependências
             |
     Controllers / Session        Controle do fluxo
        /         \
      Views       Services        Apresentação e casos de uso
                  /    \
               Domain   Adapters Contrato de resultado / sondagens do SO
                        |
                     Linux / Windows

config/tests.json                Catálogo de IDs por plataforma
config/report.schema.json        Contrato JSON de saída (schemaVersion 2.0)
config/troubleshooting-flows.json  Regras orientativas de troubleshooting
```

## Dependências e responsabilidades

- **Controllers:** parâmetros, sessão e escolha de testes. Não consultam hardware diretamente.
- **Views:** terminal, menu, painel do equipamento e feedback; não geram relatórios.
- **Services:** validação do catálogo, diagnósticos e relatórios; recebem resultados dos Adapters.
- **Domain:** validação, estados e modelo de resultados (`OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO`, `NAO_SUPORTADO`).
- **Adapters:** isolamento de CIM/PowerShell no Windows e `/proc`, `/sys` e ferramentas de sistema no Linux.
- **App:** composição. No Windows usa scriptblocks para injeção; no Linux usa composição funcional por `source`.

## Evolução 2.0.3

O legado `src/{Controllers,Core,Helpers,Models,RulesEngine,Services,Validators,Views}` foi retirado da árvore atual. A coleta anteriormente implementada pelos quatro módulos PowerShell utilizados na v2.0.2 está agora no `WindowsDiagnosticAdapter.ps1`, importado explicitamente por `App/Bootstrap.ps1`. O Controller não chama mais `Initialize-OnsLegacy` e não há estado global `FssState`.

As ferramentas opcionais de suporte não são carregadas automaticamente. O coletor C++20 experimental foi retirado por não fazer parte dos diagnósticos executados; pode ser recuperado de commits históricos se houver necessidade concreta.

## Segurança e compatibilidade

- IDs de testes e argumentos públicos Linux/Windows preservados em relação à v2.0.2.
- `schemaVersion=2.0` permanece, com JSON, TXT e HTML.
- Coletas locais e passivas por padrão; rede externa exige autorização, impressão física exige consentimento.
- Sem criação de OS obrigatória, sem elevação automática de privilégios, sem reparos por padrão.
- A remoção de shims internos (`Start.ps1`, `src/linux/probes.sh`, `src/linux/equipment.sh` e `src/windows/Equipment.ps1`) pode afetar integrações não oficiais que importavam arquivos internos. Veja [`CLEANUP_2.0.3.md`](CLEANUP_2.0.3.md).
- O código PowerShell não foi executado em Windows real neste release. Há testes mockados em `tests/architecture-windows.ps1` e `tests/adapters-windows.ps1` para rodar em PowerShell 7.4.6.

## Testes

```bash
bash tests/run-linux.sh
```

```powershell
pwsh -NoProfile -File ./tests/architecture-windows.ps1
pwsh -NoProfile -File ./tests/adapters-windows.ps1
```

## Novos casos de uso — v2.1.0

- `UsbMonitorService`: inicia uma sessão por amostragem, compara enumerações e escreve `usb-eventos.jsonl`; a View do terminal permite `\q` para encerramento. Uma segunda janela é aberta via emulador gráfico no Linux ou `Start-Process` no Windows.
- `PrintService`: valida quantidade e consentimento, gera comprovantes numerados, orquestra o lote e registra sucesso **do envio ao spooler**. Não alega impressão física concluída.
- `UsbMonitorAdapter`: lê `sysfs` (Linux) ou PnP via CIM (Windows). Nenhum acesso elétrico ou envio de dados pela USB.
- `PrintAdapter`: enfileira tarefas normais via CUPS/Out-Printer, ou RAW ESC/POS somente com confirmação de compatibilidade e guilhotina. Windows RAW usa WinSpool via C# P/Invoke, compilado localmente pelo `Add-Type`.
- `config/report.schema.json` permanece em `schemaVersion=2.0`. As novas operações são testes com IDs `usb_monitor`/`print_batch` nos resultados da sessão; evidências completas são arquivos adicionais junto do laudo.

### Garantias e limitações

- Saída por `\q` termina a sessão e fecha a **janela secundária**; Linux exige ENTER, Windows reconhece diretamente. Falhas abruptas de energia ou encerramento forçado podem impedir geração dos laudos finais.
- A sondagem de dispositivos é periódica e pode perder eventos breves, sem medir estabilidade de sinal.
- A impressão RAW não é convertida por driver: depende de fila e firmware ESC/POS compatíveis. Com `--cut-after-each`, o comando `GS V` é inserido **após cada comprovante**.
- Máximo de 100 comprovantes; impressão/corte jamais iniciados durante os testes automatizados (adapters mockados).
- Hardware real Windows e impressoras físicas permanecem pendentes de homologação.

### Adaptadores de terminal (v2.1.0, atualização de compatibilidade)

- No Linux, a seleção de emulador ocorre em `Adapters/TerminalAdapter.sh`, com detecção preferencial de `kgx` (GNOME Console) e suporte aos terminais anteriores. A opção `--usb-terminal` permite escolher explicitamente a interface.
- No Windows, `WindowsTerminalAdapter.ps1` prepara uma chamada segura via `-EncodedCommand` (UTF-16LE), permitindo iniciar a sessão USB em **PowerShell 7** ou **CMD**. `OnSiteSuite.cmd` é apenas um ponto de entrada para CMD; o motor continua sendo PowerShell 7.
- O coletor de eventos e gerador de laudos continuam na Service Layer, independente do terminal escolhido.
