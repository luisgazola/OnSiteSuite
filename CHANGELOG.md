# Changelog

## 2.0.2 — Refatoração MVC + Service Layer

- Reorganizados os executores Linux e Windows em **App, Controllers, Domain, Services, Views e Adapters**.
- Reduzidos `src/linux/runner.sh` e `src/windows/Runner.ps1` a lançadores mínimos.
- Catálogo e validação de testes separados de leitura de hardware e de apresentação.
- Serviços de diagnóstico isolados de menus, coletores e persistência de relatórios.
- Relatórios JSON/TXT/HTML movidos para ReportService por plataforma, mantendo `schemaVersion: 2.0`.
- Introduzida injeção explícita de scriptblocks no PowerShell e composição central das funções Bash.
- Movidos menu, painel e checklist para as camadas de apresentação.
- Adicionados testes de Services com adapters simulados, contrato JSON e guardrails de segurança.
- Mantidos parâmetros públicos, IDs de testes e o histórico do núcleo PowerShell legado.
- **Homologação Windows real pendente.** Qt, testes físicos de USB e guilhotina continuam fora do escopo.


## 2.0.1 — Identificação do equipamento na abertura

- Painel inicial no terminal com autoria da Excelsior Soluções e crédito a Luís Gazola.
- Identificação local de SO, número de série, Service Tag, marca, modelo, tipo, CPU, RAM e discos.
- Classificação Desktop/Notebook/AIO via chassis do firmware; sem inventar informações ausentes.
- Novos comandos `--info` / `--show-info` no Linux e `-InfoOnly` / `-ShowInfo` no Windows.
- Inventário persistido nos três formatos de relatório e campo JSON `equipamento` (schema 2.0 compatível).
- Testes automatizados Linux ampliados; adaptador PowerShell requer homologação Windows.
- Publicação orientada para nova tag `v2.0.1`, preservando `v2.0.0` e histórico anterior.


## 2.0.0 — Consolidação OnSiteSuite

- Incorporado o código do FieldServiceSuite/FieldServiceToolkit 1.2.0 enviado pelo usuário.
- Renomeado produto e disponibilizados lançadores `OnSiteSuite.ps1` e `onsite.sh`.
- Criado catálogo de testes e esquema de relatórios unificados.
- Adicionados Linux CLI e adaptador Windows com testes selecionáveis, OS opcional e modo offline.
- Adicionados HTML com escape, JSON e TXT; medidas para reduzir execução não consentida.
- Incluído módulo auxiliar C++20, fluxos de troubleshooting legados e smoke tests Linux.
- Documentadas limitações de hardware e funcionalidades ainda não implementadas.
