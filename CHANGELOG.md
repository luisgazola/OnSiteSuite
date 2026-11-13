# Changelog

## 2.2.0 — USB Diagnostic Lab

- Implementado resumo por dispositivo de cada monitoramento USB, com conexões, desconexões, reconexões e estados inicial/final.
- Acrescentados `usb-resumo.json` e `usb-comparacao.json` opcionais, mantendo `usb-eventos.jsonl` e os relatórios JSON/TXT/HTML (schema principal 2.0).
- Novo parâmetro `--usb-baseline CAMINHO` (Linux) / `-UsbBaseline CAMINHO` (Windows).
- Serviços de análise separados dos adaptadores e controllers, preservando arquitetura MVC + Service Layer e a correção homologada do KGX.
- Testes Linux determinísticos, comparação de sessões, contrato e integração; testes PowerShell novos fornecidos para execução em Windows.
- Windows v2.1.0 relatado como funcional pelo responsável; novos recursos v2.2.0 ainda não homologados em Windows real.

## Correção do lançador USB v2.1.0 (sem mudança de versão)

- Corrigida mensagem de sucesso indevida: monitor USB confirma sua inicialização antes da confirmação ao usuário.
- Mensagens de erro do terminal gráfico deixam de ser descartadas, com caminho para arquivo de diagnóstico.
- O atalho `u` informa o problema e sugere `--foreground` quando a nova janela não abre.
- Adicionado teste de regressão para falha de inicialização do emulador.

## 2.1.0 — USB contínuo e impressão avançada

### Adicionado

- Monitoramento USB em segundo terminal gráfico (Linux e Windows), com interrupção por `\q`, comparação por amostragem, registro de conexões/desconexões e `usb-eventos.jsonl` junto ao laudo JSON/TXT/HTML.
- Execução limitada por amostras para testes supervisionados; intervalos configuráveis de 0,2–60 segundos.
- Sequência de impressão numerada de 1, 3, 5 ou 1–100 comprovantes, com dados de equipamento, fabricante, modelo, autoria e texto de teste.
- Modo RAW ESC/POS com comando de guilhotina após cada comprovante (`GS V 0` / `GS V 1`), com confirmação adicional de compatibilidade e consentimento.
- Integração CUPS Linux e WinSpool RAW Windows; assistentes pelo menu (`u`, `p`) e parâmetros diretos.
- Evidências `usb-eventos.jsonl` e `comprovante-impressao.txt`; testes de dispositivos e spooler simulados.

### Compatibilidade e limites

- IDs de diagnósticos anteriores, flags existentes e `schemaVersion: 2.0` preservados.
- Impressão real e corte físico não homologados; spooler aceito não significa impressão concluída.
- O Windows ainda requer testes PowerShell 7 e validação em equipamento físico.
- Não foi incluída dependência de Python no produto; C# é usado somente na integração RAW WinSpool do Windows.

## 2.0.3 — Consolidação e limpeza arquitetural

- Removidas importações em lote da base PowerShell e a dependência de `$global:FssState`.
- Migradas as quatro funcionalidades legadas ativas (hardware/desempenho, discos, bateria e drivers) para `src/windows/Adapters/WindowsDiagnosticAdapter.ps1`, sem ações destrutivas.
- Removidas as árvores PowerShell legadas e 19 documentos históricos da distribuição; histórico Git permanece íntegro.
- Centralizado o fluxo de troubleshooting em `config/troubleshooting-flows.json` para Linux e Windows, eliminando `Config/` e `KnowledgeBase/` duplicadas.
- Removidos os pontos de entrada de compatibilidade `Start.ps1`, `src/linux/probes.sh`, `src/linux/equipment.sh` e `src/windows/Equipment.ps1`. As CLIs públicas permanecem.
- Removido o componente C++ opcional, que não participava do fluxo principal e duplicava inventário; permanece recuperável no histórico Git.
- Adicionados teste de limpeza, teste de troubleshooting e testes Windows com CIM simulado (necessitam execução no PowerShell 7).
- Preservados comandos, IDs do catálogo e schemaVersion 2.0 nos relatórios JSON/TXT/HTML.
- Validados Linux e testes de regressão; Windows real continua pendente de homologação.


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

## Atualização de compatibilidade de terminais (sem mudança de versão)

- Linux GNOME: o monitor USB reconhece o **GNOME Console (`kgx`)** com `--usb-terminal kgx` e detecção automática preferencial.
- Windows: entrada `OnSiteSuite.cmd` para Prompt de Comando, com PowerShell 7 como motor obrigatório.
- Parâmetro `-UsbTerminal PowerShell|CMD|Auto` para escolher a janela do monitor, com transporte por `EncodedCommand` e sem interpolação de argumentos em comandos CMD.
- Preservados o número **2.1.0**, o contrato JSON `schemaVersion=2.0`, os relatórios e os comandos de impressão.
- `tests/terminal-linux.sh` acrescentado à suíte; `tests/terminal-windows.ps1` verifica geração de comandos sem hardware. Homologação gráfica física no Windows pendente.

## Hotfix KGX (2.1.0, sem mudança de versão)

- Corrigido `kgx --command "..."` para `kgx -- bash "${args[@]}"`, preservando o vetor de argumentos e evitando incompatibilidade de parsing do GNOME Console.
- Teste de regressão recusa expressamente o formato antigo (`--command`) e valida a confirmação por arquivo de inicialização, sem anunciar sucesso falso.
- Diagnóstico gráfico em equipamento Gentoo real depende de execução local; testes com emulador estrito aprovados.
