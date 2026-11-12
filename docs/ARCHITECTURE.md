# Arquitetura — OnSiteSuite v2.0.3

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
