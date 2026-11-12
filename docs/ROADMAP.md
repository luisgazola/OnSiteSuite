# Roadmap de capacidade — transparência

## Entregue v2.0.0 (código-fonte)

- Interface de terminal para seleção de testes Windows/Linux.
- OS opcional; execução direta de uma seleção; saída local JSON, TXT e HTML.
- Catálogo único de testes, resumo e status padronizados.
- Linux: identificador do sistema, CPU, RAM, discos, SMART opcional, bateria, rede local, USB, filas CUPS, drivers PCI, áudio enumerado, monitores DRM, journalctl e indicadores de segurança.
- Windows: adaptação dos serviços PowerShell já existentes, mais USB, impressoras, áudio, monitores, eventos e indicadores de segurança.
- C++20: coletor auxiliar de inventário básico, compilável de modo independente.
- Teste de impressão por CUPS com consentimento explícito (Linux).
- Fluxos orientativos de troubleshooting extraídos da base legada (sem executar reparos).
- Testes automatizados básicos para CLI Linux e catálogo.

## Pendências para desenvolvimento e homologação

- GUI Qt6 e painel visual interativo.
- Empacotamento/assinatura de binários de produção para Windows e Linux.
- Suite de testes em hardware real Windows e Linux/Gentoo.
- Monitoramento USB em hardware real com testes de perturbação controlada e comparação de porta/cabo/dispositivo (núcleo por amostragem implementado na v2.1.0).
- Homologação de sequência multi-job em impressoras reais, leitura de status físico e avaliação de latência/tempo de impressão.
- Homologação de guilhotina ESC/POS por fabricante e modelos, detecção de capacidades reais, abertura de gaveta autorizada e tratamento de papel (comando básico RAW implementado na v2.1.0).
- Playback/record de áudio, diagnóstico visual de display e teclado/mouse com UI.
- SMART detalhado padronizado, saúde de bateria por fabricante, estresse/memória prolongados.
- Procedimentos de reparo com rollback, confirmação e auditoria.
- Banco local opcional, histórico de relatórios, comparação temporal, API autenticada e integração opcional com ExcelsiorDesk.
- CI Windows real, Pester, análise estática, assinatura, SBOM e releases reproduzíveis.

**Não classificar pendências como implementadas.**

## Implementado na v2.0.1
- Tela inicial com identificação local de equipamento no Linux e Windows (Windows pendente de homologação).
- Inventário em relatórios JSON/TXT/HTML, com compatibilidade do schema 2.0.
- Autoria e identidade Excelsior Soluções no terminal e laudos.

## Atualização v2.0.3

- Consolidação das camadas MVC + Service Layer e remoção do código PowerShell antigo concluídas na árvore de distribuição.
- Interfaces públicas e contrato JSON v2 preservados; shims internos antigos descontinuados.
- C++20 poderá retornar apenas se houver uma necessidade concreta de coleta de baixo nível não atendida pelos adaptadores atuais.
- Prioridade de qualidade: executar testes PowerShell mockados e validar em máquinas Windows reais antes de comercializar como ferramenta homologada.

## Implementado em v2.1.0 (não equivale a homologação física)

- Monitor contínuo USB via segundo terminal no Windows/Linux, com `\q` e relatório de eventos (amostragem).
- Sequência de 1, 3, 5 e quantidade customizada de comprovantes (limite 100); adaptação CUPS/Out-Printer e WinSpool RAW.
- Comando de corte ESC/POS após cada comprovante com confirmação de compatibilidade e autorização explícitas.
- Testes Linux com sysfs e spooler simulados para eventos USB, impressão, contador e bytes de guilhotina.
- Testes PowerShell mockados fornecidos para execução futura no Windows; sem homologação real na entrega.
