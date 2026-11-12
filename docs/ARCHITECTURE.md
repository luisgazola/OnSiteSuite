# Arquitetura OnSiteSuite 2.0.2 — MVC + Service Layer

**Escopo:** CLI Windows (PowerShell) e Linux (Bash), diagnósticos locais e relatórios JSON/TXT/HTML.
O projeto usa **separação por responsabilidades**, inspirada em MVC e Clean Architecture, adequada a utilitários de terminal. Não se trata de MVC web com framework ou servidor HTTP.

## Fluxo de dependências

```text
[OnSiteSuite.ps1] / [onsite.sh]                ENTRYPOINTS
               |
     [App/Bootstrap]                          COMPOSITION ROOT
               |
     [Controllers/SessionController]          CONTROLADOR (fluxo/sessão)
               |
     +---------+--------------------------+
     |                                    |
 [Views]                              [Services]
 menu, painel e feedback             catálogo, diagnóstico,
                                    troubleshooting, laudos
                                            |
                                  [Domain/Result contract]
                                            |
                                   [Adapters de SO]
                                 Windows: CIM/PSM1 legado
                                 Linux: /proc,/sys,lsblk...

                        [config/tests.json]
                        [config/report.schema.json]
```

O diagrama representa **fluxo de execução**, não que Domain importe o adaptador. As regras e o contrato de resultados ficam independentes da API do sistema operacional. Services coordenam os adapters e criam o relatório; Views apresentam dados e recebem seleção.

## Mapa dos componentes

| Responsabilidade | Linux | Windows |
| --- | --- | --- |
| Entrypoint | `onsite.sh`, `src/linux/runner.sh` | `OnSiteSuite.ps1`, `src/windows/Runner.ps1` |
| Composição | `src/linux/App/Bootstrap.sh` | `src/windows/App/Bootstrap.ps1` (`New-OnsWindowsDependencies`) |
| Controller | `src/linux/Controllers/SessionController.sh` | `src/windows/Controllers/SessionController.ps1` |
| Models/Domain | `src/linux/Domain/Result.sh` | `src/windows/Domain/DiagnosticResult.ps1` |
| Services | `src/linux/Services/*.sh` | `src/windows/Services/*.ps1` |
| Views | `src/linux/Views/*.sh` | `src/windows/Views/*.ps1` |
| Adapters | `src/linux/Adapters/*.sh` | `src/windows/Adapters/*.ps1`, PowerShell `src/Services/*.psm1` |
| Contrato externo | `config/tests.json`, `config/report.schema.json` | Os mesmos dois arquivos |

## Regras arquiteturais

1. **Views** não acessam diretamente DMI, CIM, SMART, arquivos de relatório ou serviços de rede. Apenas mostram dados e leem entradas.
2. **Controllers** interpretam argumentos e orquestram casos de uso. Não contêm HTML, jq para formatação de laudos, Get-CimInstance ou sondagens físicas.
3. **Application Services** executam o catálogo, os diagnósticos e a exportação; dependem de contratos e adapters, e não importam diretamente UI.
4. **Adapters** isolam comandos e APIs específicos do Windows/Linux. Resultados de ambiente são sempre normalizados para o contrato.
5. **Domain/Result** contém formato e validação do resultado de cada teste. Estados permitidos: `OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO`, `NAO_SUPORTADO`.
6. **Composition root** monta os serviços. Windows utiliza scriptblocks que podem ser substituídos por doubles; Bash carrega as funções necessárias em sessão única, sem container de reflexão.
7. **Relatórios** preservam `schemaVersion: "2.0"`, `product`, `atendimento`, `equipamento`, `tests`, `summary` e formatos JSON/TXT/HTML.
8. **Sem OS obrigatória; sem internet por padrão; sem elevação automática; sem impressão física sem consentimento.**

## Preservação do legado

A base FieldServiceToolkit 1.2.0 foi mantida em `src/{Controllers,Models,Views,Services,Helpers,Validators,Core,RulesEngine}`. O adaptador Windows invoca `src/Services/*.psm1` para hardware, bateria, drivers e rede. A pasta legada não foi artificialmente declarada como arquitetura ativa; o fluxo v2.0.2 inicia em `src/windows/App/Bootstrap.ps1`.

`src/linux/probes.sh`, `src/linux/equipment.sh` e `src/windows/Equipment.ps1` são *shims* de importação para compatibilidade com integrações anteriores, sem conter uma segunda implementação.

## Limites e compromissos

- O contrato externo dos relatórios é único, mas existem **dois renderizadores** específicos de plataforma (`ReportService.sh` e `ReportService.ps1`). Eles devem receber testes de paridade conforme a homologação Windows avance.
- Algumas funções legadas Windows utilizam `$global:FssState`. O adapter contém essa dependência, que merece substituição gradual na versão seguinte; não é correto afirmar que toda a aplicação esteja livre de estado global.
- Bash usa **escopo dinâmico local** para passar o contexto do teste (`CURRENT_TEST`, `CURRENT_TITLE`) ao contrato durante uma sondagem. Não há mutação permanente desses campos.
- O Windows não foi executado neste ambiente Linux. Testes de serviços PowerShell mockados foram adicionados em `tests/architecture-windows.ps1` para validação em Windows/PowerShell 7 real.
- Apenas leitura SMART e coleta de dados compatíveis são suportadas; não há teste integral de hardware, estresse, guilhotina ou GUI Qt nesta versão.

## Testes

```bash
bash tests/check-catalog.sh
bash tests/equipment-linux.sh
bash tests/smoke-linux.sh
bash tests/architecture-linux.sh
bash tests/contract-linux.sh
```

PowerShell 7 / Windows:

```powershell
pwsh -NoProfile -File ./tests/architecture-windows.ps1
```

Para novos testes, mantenha a compatibilidade da CLI, faça mocks para adapters e valide **contrato, estados inconclusivos, privacidade e consentimento**. Consulte `docs/RELEASE_2.0.2.md`.
