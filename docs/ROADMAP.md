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
- Monitoramento USB contínuo de desconexões e correlação cabo/porta/dispositivo.
- Teste de impressão sequencial multi-job, latência de fila, resposta do hardware.
- Guilhotina ESC/POS e abertura de gaveta com whitelist de modelos e autorização.
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
