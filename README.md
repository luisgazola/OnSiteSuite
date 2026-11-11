# OnSiteSuite v2.0.0

**Excelsior Soluções — Field Service · Diagnóstico · Troubleshooting · Laudos**

O **OnSiteSuite** combina a base do projeto **FieldServiceToolkit/FieldServiceSuite v1.2.0** com uma arquitetura de suíte de diagnóstico **local, offline-first e multiplataforma**.

> **Situação:** entrega de código-fonte integrado com CLI Linux executada em ambiente de testes. Adaptador Windows disponível, mas **ainda não homologado em Windows real**. Não confundir com lançamento comercial certificado.

## Começar rapidamente

### Linux (incluindo Gentoo)

Dependência obrigatória: **Bash 5.2** e **jq 1.7**. Execução validada com Bash 5.2.37 e jq 1.7 neste ambiente. As demais ferramentas são opcionais e o relatório informa quando um recurso não está disponível.

```bash
# Dependência de leitura/geração JSON no Gentoo
sudo emerge -av app-misc/jq

cd OnSiteSuite-v2.0.0
chmod +x onsite.sh
./onsite.sh                   # seleção interativa, sem OS obrigatória
./onsite.sh --list-tests
./onsite.sh --tests system,cpu,memory,storage,battery,usb,printer
./onsite.sh --all --client "Empresa Exemplo" --technician "Técnico"
```

Para ampliar os testes no Gentoo, instale apenas se necessário: `sys-apps/smartmontools` (SMART), `net-print/cups` (cliente de impressão), `sys-apps/pciutils` (detalhes PCI), `sys-apps/usbutils` (USB) e `sys-apps/lm-sensors` (sensores). Pacotes podem exigir configuração de impressora ou permissões adicionais.

Guia de troubleshooting reaproveita a base de fluxos do FieldServiceToolkit:

```bash
./onsite.sh --tests network,troubleshooting --symptom sem_internet
./onsite.sh --tests cpu,memory,storage,troubleshooting --symptom notebook_lento
```

No Windows, use `-Tests 'troubleshooting' -Symptom 'bateria'`.

Verificações externas de conectividade são **opt-in**:

```bash
./onsite.sh --tests network --online
```

Para envio físico **autorizado** de uma página via fila CUPS (não testa guilhotina):

```bash
./onsite.sh --tests printer --print-test MINHA_FILA --yes-print
```

### Windows (PowerShell)

Perfil de dependência definido: **PowerShell 7.4.6** em Windows 10/11 (alvo de compatibilidade, **sem teste de execução nesta entrega**). O código utiliza CIM, PowerShell de Gerenciamento de Dispositivos e Serviços de Armazenamento disponíveis conforme edição/permissões. **Não validado nesta entrega em máquina Windows.**

```powershell
cd OnSiteSuite-v2.0.0
.\OnSiteSuite.ps1 -ListTests
.\OnSiteSuite.ps1                    # seleção interativa
.\OnSiteSuite.ps1 -Tests 'system,cpu,memory,storage,battery,usb,printer' -NonInteractive
.\OnSiteSuite.ps1 -All -Client 'Empresa Exemplo' -Ticket 'CH123456' -Technician 'Técnico'
.\OnSiteSuite.ps1 -Tests network -Online
```

**Não é necessário cadastrar cliente ou OS.** Use `-Ticket`, `-Client`, `-Technician`, `-Serial` no Windows ou as flags equivalentes em Linux somente quando desejado.

## Relatórios

A cada execução, são criados **três arquivos locais**, no diretório `Reports/AAAA/MM/DD/SESSAO/`:

- `relatorio.json` — estrutura canônica para importação/automação.
- `relatorio.txt` — leitura rápida e histórico textual.
- `relatorio.html` — laudo legível e imprimível pelo navegador, sem conexão.

Os estados são `OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO`, `NAO_SUPORTADO`. **OK não significa aprovação integral do hardware**: a explicação de cada teste delimita o que foi realmente medido.

## Testes oferecidos

`system`, `cpu`, `memory`, `storage`, `smart`, `battery`, `network`, `usb`, `printer`, `drivers`, `audio`, `display`, `logs`, `security`, `checklist`, `troubleshooting`.

Em ambos os sistemas há sondagens **passivas**, não testes físicos completos. `smart`, sensores, bateria, impressora e monitores variam conforme equipamento, fabricante, privilégios e drivers. `checklist` pede confirmação manual quando há terminal interativo. O teste de impressão CUPS requer consentimento explícito.

## Estrutura

```text
OnSiteSuite-v2.0.0/
├── onsite.sh                     # Linux
├── OnSiteSuite.ps1               # Windows
├── config/tests.json             # catálogo compartilhado
├── config/report.schema.json     # contrato de laudo
├── src/linux/                    # sondas Linux e runner
├── src/windows/Runner.ps1        # adaptador Windows
├── src/{Controllers,Services,...} # módulos preservados do projeto original
├── native/                       # utilitário opcional C++20
├── tests/                        # smoke tests Linux
├── docs/                         # arquitetura e roadmap
├── Config/ e KnowledgeBase/      # artefatos anteriores preservados
└── Reports/                      # relatórios locais (ignorados no Git)
```

### Compilar coletor nativo opcional (C++20)

```bash
cmake -S native -B build/native -DCMAKE_BUILD_TYPE=Release
cmake --build build/native
./build/native/onsite-probe --json
```

O coletor native é auxiliar, sem dependências externas e não obrigatório para uso da CLI.

### Testar Linux

```bash
bash tests/check-catalog.sh
bash tests/smoke-linux.sh
```

## Segurança

- **Offline por padrão;** o aplicativo não envia telemetria e não altera estado do equipamento automaticamente.
- Não executa reparos, flash de BIOS, testes de estresse, corte de papel ou ações privilegiadas sem implementação e confirmação apropriadas.
- Identificação de uma fila de impressão não prova comunicação, qualidade de impressão nem estado da guilhotina.
- Laudos podem conter nomes, hostname, IP e detalhes de logs; trate-os como informação sensível.

## Integração ExcelsiorDesk

O contrato JSON v2 permite futura integração com OS no ExcelsiorDesk, **ainda não implementada**. OnSiteSuite é utilizável sem SaaS, banco, Docker e internet.

## Referências e licença

Código de origem de **FieldServiceSuite v1.2.0**, sob licença MIT, preservado e adaptado. Consulte `LICENSE`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md` e `docs/SECURITY.md`. As fontes de engenharia de software fornecidas pelo projeto serviram de diretrizes de modularização, manutenibilidade e testes; nenhum conteúdo dos livros foi reproduzido no código.

## Repositório oficial e migração do FieldServiceToolkit

O projeto continua a história do repositório **FieldServiceToolkit**, renomeado para **OnSiteSuite**.

- URL oficial após renomeação: https://github.com/luisgazola/OnSiteSuite
- Migração sem perder o histórico: [`docs/REPOSITORY_MIGRATION.md`](docs/REPOSITORY_MIGRATION.md)
- Publicação automatizada: `bash scripts/publish-github.sh`
- Caso já tenha renomeado pelo navegador: `bash scripts/publish-github.sh --already-renamed`

**Não use `git init` para criar um repositório novo:** a migração deve gerar um commit sobre a branch
`main` preexistente e depois uma tag anotada `v2.0.0`.
