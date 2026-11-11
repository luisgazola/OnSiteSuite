# OnSiteSuite v2.0.1

**Excelsior Soluções — Field Service · Diagnóstico · Troubleshooting · Laudos**

O **OnSiteSuite** combina a base do projeto **FieldServiceToolkit/FieldServiceSuite v1.2.0** com uma arquitetura de suíte de diagnóstico **local, offline-first e multiplataforma**.

> **Situação:** entrega de código-fonte integrado com CLI Linux executada em ambiente de testes. Adaptador Windows disponível, mas **ainda não homologado em Windows real**. Não confundir com lançamento comercial certificado.

## Abertura de terminal e identificação do equipamento (novidade 2.0.1)

Ao executar **sem parâmetros** em um terminal interativo, a primeira tela apresenta o nome
**OnSiteSuite v2.0.1**, a descrição da suíte e sua identificação como projeto da
**Excelsior Soluções em Tecnologia**, com crédito ao desenvolvedor **Luís Gazola**.
Em seguida, exibe um **inventário local**: sistema operacional, número de série,
Service Tag (quando identificável), marca, modelo, classificação Desktop/Notebook/AIO,
processador, RAM e discos. Logo abaixo aparece o menu de testes, com seleção individual.

- **Linux:** informações de DMI quando acessíveis, `/etc/os-release`, `/proc` e `lsblk`.
- **Windows:** inventário via CIM/WMI, sem necessidade de instalar agente.
- **Não identificado:** equipamento sem dados confiáveis, bloqueado por permissões ou com campo genérico de firmware.
- **Service Tag:** em equipamentos Dell reconhecidos, corresponde ao identificador de série; em outras marcas não é presumida.
- **Execução com parâmetros:** não imprime o painel por padrão, preservando o uso em automações.
  Use `--show-info` (Linux) ou `-ShowInfo` (Windows) para também exibi-lo.
- **Somente identificação:** `./onsite.sh --info` ou `./OnSiteSuite.ps1 -InfoOnly`, sem iniciar testes nem gerar laudos.
- **Privacidade:** número de série é informação potencialmente sensível; não compartilhe relatórios publicamente.

Os mesmos dados são incluídos no objeto `equipamento` do relatório JSON, bem como nos
laudos TXT/HTML. O esquema `2.0` é mantido por compatibilidade, com o campo adicional
`equipamento` opcional para consumidores de relatórios antigos. A versão do aplicativo passa a `2.0.1`.

## Começar rapidamente

### Linux — Debian/Ubuntu, Fedora e Arch Linux

Requisitos: **Bash 5.2 ou superior** e **jq 1.7 ou superior**. A execução foi validada com Bash 5.2.37 e jq 1.7 neste ambiente. As demais ferramentas são opcionais: o relatório informa quando não estão disponíveis.

Instale `jq` com o gerenciador de pacotes da sua distribuição (**utilize apenas o bloco correspondente**):

**Debian / Ubuntu**

```bash
sudo apt update
sudo apt install -y jq
```

**Fedora**

```bash
sudo dnf install -y jq
```

**Arch Linux**

```bash
sudo pacman -S --needed jq
```

Verifique as versões instaladas antes de executar:

```bash
bash --version | head -n 1
jq --version
```

Clone a versão específica do projeto e execute os diagnósticos:

```bash
git clone --branch v2.0.1 --depth 1 https://github.com/luisgazola/OnSiteSuite.git
cd OnSiteSuite
chmod +x onsite.sh
./onsite.sh                   # painel do equipamento + menu interativo, sem OS obrigatória
./onsite.sh --info            # apenas dados do equipamento; não cria laudo
./onsite.sh --list-tests
./onsite.sh --tests system,cpu --show-info    # identifica mesmo em execução direta
./onsite.sh --tests system,cpu,memory,storage,battery,usb,printer
./onsite.sh --all --client "Empresa Exemplo" --technician "Técnico"
```

Se utilizar o ZIP da versão 2.0.1 em vez do Git, entre na pasta extraída (por exemplo, `cd OnSiteSuite-v2.0.1`) antes dos comandos `chmod` e `./onsite.sh`.

Para ampliar as sondagens, instale **apenas os pacotes opcionais necessários**:

| Recurso | Debian/Ubuntu | Fedora | Arch Linux |
| --- | --- | --- | --- |
| SMART (discos) | `smartmontools` | `smartmontools` | `smartmontools` |
| Cliente de impressão CUPS | `cups-client` | `cups-client` | `cups` |
| Identificação PCI | `pciutils` | `pciutils` | `pciutils` |
| Identificação USB | `usbutils` | `usbutils` | `usbutils` |
| Sensores | `lm-sensors` | `lm_sensors` | `lm_sensors` |

A disponibilidade dos testes depende do hardware, drivers, permissões e configuração local de impressoras.

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
cd OnSiteSuite-v2.0.1
.\OnSiteSuite.ps1 -ListTests
.\OnSiteSuite.ps1                    # painel e menu de testes
.\OnSiteSuite.ps1 -InfoOnly         # identifica sem iniciar testes
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
OnSiteSuite-v2.0.1/
├── onsite.sh                     # Linux
├── OnSiteSuite.ps1               # Windows
├── config/tests.json             # catálogo compartilhado
├── config/report.schema.json     # contrato de laudo
├── src/linux/                    # sondas Linux, inventário e runner
├── src/windows/{Runner,Equipment}.ps1 # adaptador e inventário Windows
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
bash tests/equipment-linux.sh
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

## Repositório oficial e publicação v2.0.1

O repositório **FieldServiceToolkit** já foi renomeado para **OnSiteSuite**,
preservando o histórico Git original: https://github.com/luisgazola/OnSiteSuite.

A nova versão pode ser publicada na branch `main` e marcada com a **nova tag `v2.0.1`**.
Nunca sobrescreva ou mova a tag anterior `v2.0.0`. Veja
[`docs/RELEASE_2.0.1.md`](docs/RELEASE_2.0.1.md) e o script `bash scripts/publish-github.sh`.

**Nota:** até a nova tag ser publicada no GitHub, os exemplos de clone por `--branch v2.0.1`
só funcionarão após essa publicação. O ZIP desta entrega pode ser executado diretamente.
