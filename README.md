<div align="center">

# OnSiteSuite

**Diagnóstico técnico de campo, inventário de equipamentos e relatórios em uma única suíte de terminal.**

**Um projeto da Excelsior Soluções em Tecnologia** · Desenvolvido por **Luís Gazola**

![Versão](https://img.shields.io/badge/vers%C3%A3o-2.0.1-2563eb)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-16a34a)
![Linux](https://img.shields.io/badge/Linux-CLI%20testada-16a34a)
![Windows](https://img.shields.io/badge/Windows-homologa%C3%A7%C3%A3o%20pendente-f59e0b)
![Operação](https://img.shields.io/badge/opera%C3%A7%C3%A3o-offline--first-475569)

[Conheça o projeto](#1-o-projeto) · [Funcionalidades](#2-o-que-a-su%C3%ADte-faz) · [Instalar](#4-instala%C3%A7%C3%A3o) · [Comandos](#5-guia-r%C3%A1pido-de-uso) · [Contribuir](#11-como-contribuir)

</div>

---

## 1. O projeto

O **OnSiteSuite** é uma suíte **open source** para auxiliar profissionais de **Field Service, Help Desk, suporte técnico e manutenção de computadores** na coleta de informações do equipamento, execução de verificações selecionáveis, consulta a procedimentos de troubleshooting e geração de laudos técnicos.

Ele nasceu de uma necessidade recorrente no atendimento presencial: reunir informações confiáveis sobre o equipamento e documentar um diagnóstico exige alternar entre comandos, utilitários e anotações dispersas. Em atendimentos com pouco tempo, rede indisponível ou acesso restrito, esse fluxo se torna ainda menos eficiente.

A proposta é reunir as etapas essenciais em uma experiência de terminal objetiva:

**Identificar o equipamento → Escolher as verificações → Coletar evidências → Interpretar resultados → Gerar o relatório.**

O programa funciona localmente, sem exigir conta, servidor, banco de dados, contêiner ou abertura prévia de ordem de serviço (OS). Os campos de cliente, chamado e técnico são **opcionais**.

### Para quem foi criado?

| Público | Aplicação prática |
| --- | --- |
| **Técnicos de campo e assistência** | Levantamento inicial de hardware e documentação do atendimento. |
| **Equipes de suporte N1/N2 e service desk** | Coleta consistente de indicadores e evidências para escalonamento. |
| **Administradores de sistemas** | Diagnósticos pontuais e execução por parâmetros em estações Linux/Windows. |
| **Desenvolvedores e entusiastas** | Estudo e contribuição em automação, PowerShell, Bash, C++20, JSON Schema e arquitetura modular. |

### De onde veio a versão 2.0.1?

O projeto evolui o [FieldServiceToolkit](https://github.com/luisgazola/OnSiteSuite) (antigo nome do repositório), originalmente baseado em **FieldServiceSuite v1.2.0**. A série 2.x unificou o catálogo e o formato dos relatórios para Linux e Windows. Na **v2.0.1**, a abertura ganhou a **identificação do equipamento antes do menu de testes**, com identidade visual e autoria da Excelsior Soluções.

> **Estado do projeto:** a CLI e os testes automatizados Linux foram executados no ambiente de desenvolvimento. Há um adaptador PowerShell para Windows, mas ele **ainda precisa ser homologado em máquinas Windows reais**. O OnSiteSuite é uma ferramenta de apoio ao diagnóstico, não um certificador de integridade de hardware.

## 2. O que a suíte faz

- **Identificação do equipamento:** sistema operacional, marca, modelo, número de série, Service Tag quando aplicável, classificação Desktop/Notebook/AIO, CPU, RAM e armazenamento.
- **Testes selecionáveis:** execute somente as verificações relevantes; use o menu ou chame IDs diretamente pela CLI.
- **Sondagens de sistema e periféricos:** dispositivos USB, interfaces de rede, impressoras configuradas, áudio, monitores, drivers, logs e indicadores parciais de segurança.
- **Armazenamento e bateria:** inventário de discos, leitura SMART quando disponível, dados de bateria e energia fornecidos pelo sistema.
- **Troubleshooting guiado:** orientações para sintomas como notebook lento, ausência de internet e problemas de bateria, sem reparos automáticos.
- **Laudos locais:** saídas **JSON, TXT e HTML**, com informações da sessão, equipamento, resultados, evidências e recomendações.
- **Operação offline-first:** nenhuma sondagem externa de rede é realizada sem a opção explícita correspondente.

### Catálogo de verificações

| Grupo | IDs para linha de comando | Alcance atual |
| --- | --- | --- |
| Sistema e desempenho | `system`, `cpu`, `memory` | Inventário e métricas disponíveis; não realiza teste de estresse ou teste físico integral de RAM. |
| Armazenamento e energia | `storage`, `smart`, `battery` | Discos, indicadores SMART e bateria conforme sistema, permissões e hardware. |
| Conectividade e periféricos | `network`, `usb`, `printer`, `drivers` | Configurações de rede, dispositivos e filas; não comprova estabilidade física do USB. |
| Experiência e eventos | `audio`, `display`, `logs`, `security` | Enumeração de dispositivos e indicadores pontuais; não substitui testes audiovisuais ou auditoria de segurança. |
| Apoio ao atendimento | `checklist`, `troubleshooting` | Checklist manual e instruções guiadas para sintomas conhecidos. |

**Importante:** os estados `OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO` e `NAO_SUPORTADO` descrevem o **resultado da verificação específica**. Um `OK` não garante que todo o componente esteja íntegro.

## 3. Prévia da experiência no terminal

Ao iniciar sem argumentos em um terminal interativo, o programa apresenta o inventário e, abaixo dele, o menu de testes. Os dados a seguir são **fictícios**, apenas para ilustrar a interface.

```text
======================================================================
  OnSiteSuite v2.0.1 | EXCELSIOR SOLUÇÕES
  Suíte de diagnóstico, troubleshooting e laudos de Field Service
  Autoria: Excelsior Soluções em Tecnologia
  Desenvolvedor: Luís Gazola
----------------------------------------------------------------------
  IDENTIFICAÇÃO DO EQUIPAMENTO (coleta local; sem alterações)
  Sistema operacional:       Debian GNU/Linux
  Número de série:           EXEMPLO123
  Service Tag:               Não identificado
  Marca:                     Fabricante Exemplo
  Modelo:                    Modelo Exemplo
  Tipo:                      Notebook
  Processador:               Processador Exemplo
  Memória RAM:               16.0 GiB
  Armazenamento:             nvme0n1 476G
----------------------------------------------------------------------
  Dados ausentes não são estimados. Confira as etiquetas quando necessário.
======================================================================

--- MENU DE TESTES | OnSiteSuite v2.0.1 ---
 1. [x] Identificação do sistema
 2. [x] Processador e temperaturas disponíveis
 3. [x] Memória RAM
 ...
 a=Todos os testes passivos | r=Executar | q=Sair
 Escolha:
```

**Como navegar:** digite o **número** para marcar/desmarcar um teste; `a` seleciona as sondagens passivas; `r` executa; `q` sai. Os testes podem ser executados sem preencher OS ou cadastro de cliente.

## 4. Instalação

### 4.1 Linux — Debian/Ubuntu, Fedora e Arch Linux

**Requisitos mínimos de execução:** Bash **5.2+** e `jq` **1.7+**. O conjunto de testes Linux foi executado com Bash 5.2.37 e jq 1.7; recursos como SMART e sensores podem exigir outros utilitários.

Instale o `jq` na sua distribuição:

<details>
<summary><strong>Debian / Ubuntu</strong></summary>

```bash
sudo apt update
sudo apt install -y jq
```

</details>

<details>
<summary><strong>Fedora</strong></summary>

```bash
sudo dnf install -y jq
```

</details>

<details>
<summary><strong>Arch Linux</strong></summary>

```bash
sudo pacman -S --needed jq
```

</details>

Confira os requisitos:

```bash
bash --version | head -n 1
jq --version
```

**Instalação a partir do Git (versão específica):**

```bash
git clone --branch v2.0.1 --depth 1 https://github.com/luisgazola/OnSiteSuite.git
cd OnSiteSuite
chmod +x onsite.sh
./onsite.sh
```

**Sem Git:** baixe o [ZIP do código-fonte v2.0.1](https://github.com/luisgazola/OnSiteSuite/archive/refs/tags/v2.0.1.zip), extraia e, no terminal, entre na pasta extraída (`OnSiteSuite-2.0.1`). Em seguida execute `chmod +x onsite.sh` e `./onsite.sh`.

**Dependências opcionais:**

| Função | Debian / Ubuntu | Fedora | Arch Linux |
| --- | --- | --- | --- |
| SMART | `smartmontools` | `smartmontools` | `smartmontools` |
| Impressão via CUPS | `cups-client` | `cups-client` | `cups` |
| Dispositivos PCI | `pciutils` | `pciutils` | `pciutils` |
| Dispositivos USB | `usbutils` | `usbutils` | `usbutils` |
| Sensores | `lm-sensors` | `lm_sensors` | `lm_sensors` |

Instale somente o que for necessário para o atendimento. Algumas leituras podem continuar indisponíveis por limitações do firmware, drivers ou permissões.

### 4.2 Windows 10/11 — PowerShell 7

**Alvo de compatibilidade documentado:** PowerShell **7.4.6** (ainda sem homologação Windows real nesta versão). Use **PowerShell 7 (`pwsh`)**, não presuma compatibilidade com o Windows PowerShell 5.1.

1. Instale o [PowerShell 7.4.6](https://github.com/PowerShell/PowerShell/releases/tag/v7.4.6) e o [Git para Windows](https://git-scm.com/downloads/win) se desejar clonar via Git. Também é possível baixar o ZIP sem instalar Git.
2. Abra o **PowerShell 7** e confira `pwsh --version`.
3. Escolha **uma** das formas de obter o projeto:

**Via Git:**

```powershell
git clone --branch v2.0.1 --depth 1 https://github.com/luisgazola/OnSiteSuite.git
Set-Location .\OnSiteSuite
```

**Via ZIP, sem Git:** baixe o [código-fonte v2.0.1](https://github.com/luisgazola/OnSiteSuite/archive/refs/tags/v2.0.1.zip), extraia e acesse a pasta pelo PowerShell 7, por exemplo:

```powershell
Set-Location "$HOME\Downloads\OnSiteSuite-2.0.1"
```

Se a pasta foi extraída em outro local, ajuste o caminho. Para iniciar:

```powershell
.\OnSiteSuite.ps1
```

Se o Windows bloquear a execução de um script baixado, **verifique a origem e o conteúdo antes de desbloqueá-lo**. Evite alterar permanentemente a política de execução do computador. Consulte a [documentação da Microsoft sobre políticas de execução](https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy).

## 5. Guia rápido de uso

Os exemplos abaixo devem ser executados **dentro da pasta do projeto**. A abertura interativa é a maneira mais fácil de começar.

### Linux (Bash)

```bash
./onsite.sh                                         # painel + menu interativo
./onsite.sh --info                                  # somente identificação; não cria laudo
./onsite.sh --list-tests                            # IDs dos testes disponíveis
./onsite.sh --tests system,cpu,memory,storage       # seleção direta
./onsite.sh --tests system,cpu --show-info          # mostra inventário antes da coleta
./onsite.sh --all                                   # todas as sondagens passivas
./onsite.sh --tests network --online                # autoriza testes externos de rede
./onsite.sh --tests storage,smart --output ./Laudos # escolhe destino dos relatórios
./onsite.sh --help                                  # todas as opções de CLI
```

**Com dados opcionais do atendimento:**

```bash
./onsite.sh --all --client "Empresa Exemplo" --ticket "CH-1234" --technician "Técnico Responsável"
```

**Troubleshooting orientativo:**

```bash
./onsite.sh --tests network,troubleshooting --symptom sem_internet
./onsite.sh --tests cpu,memory,storage,troubleshooting --symptom notebook_lento
./onsite.sh --tests battery,troubleshooting --symptom bateria
```

**Teste físico de impressão (Linux/CUPS):** só use com uma fila configurada e autorização explícita:

```bash
./onsite.sh --tests printer --print-test MINHA_FILA --yes-print
```

O envio do trabalho à fila **não confirma** que a impressão saiu corretamente e **não aciona a guilhotina**.

### Windows (PowerShell 7)

```powershell
.\OnSiteSuite.ps1                                                  # painel + menu interativo
.\OnSiteSuite.ps1 -InfoOnly                                        # somente identificação
.\OnSiteSuite.ps1 -ListTests                                       # lista os testes
.\OnSiteSuite.ps1 -Tests 'system,cpu,memory,storage' -NonInteractive
.\OnSiteSuite.ps1 -Tests 'system,cpu' -ShowInfo -NonInteractive
.\OnSiteSuite.ps1 -All                                            # todas as sondagens passivas
.\OnSiteSuite.ps1 -Tests network -Online                           # consulta externa autorizada
.\OnSiteSuite.ps1 -Tests troubleshooting -Symptom bateria -NonInteractive
```

**Com dados opcionais do atendimento:**

```powershell
.\OnSiteSuite.ps1 -All -Client 'Empresa Exemplo' -Ticket 'CH-1234' -Technician 'Técnico Responsável'
```

A ferramenta **não solicita elevação automaticamente**. Determinadas leituras podem resultar em `INCONCLUSIVO` ou `NAO_SUPORTADO` quando faltam permissões ou APIs do sistema.

### Referência curta de parâmetros

| Objetivo | Linux | Windows |
| --- | --- | --- |
| Identificar o equipamento | `--info` | `-InfoOnly` |
| Mostrar identificação junto com teste | `--show-info` | `-ShowInfo` |
| Listar testes | `--list-tests` | `-ListTests` |
| Selecionar testes | `--tests cpu,memory` | `-Tests 'cpu,memory'` |
| Executar sondagens passivas | `--all` | `-All` |
| Autorizar conectividade externa | `--online` | `-Online` |
| Cliente e chamado opcionais | `--client`, `--ticket` | `-Client`, `-Ticket` |
| Técnico responsável | `--technician` | `-Technician` |
| Sintoma orientativo | `--symptom` | `-Symptom` |
| Alterar pasta dos relatórios | `--output` | `-Output` |

## 6. Relatórios e evidências

Depois de um diagnóstico, o OnSiteSuite cria uma pasta de sessão local no formato:

```text
Reports/
└── AAAA/
    └── MM/
        └── DD/
            └── sem-os-HHMMSS-ID/
                ├── relatorio.json
                ├── relatorio.txt
                └── relatorio.html
```

- **JSON:** resultado estruturado para ferramentas, integrações e processamento posterior. Usa `schemaVersion: "2.0"`; a versão do programa é `2.0.1`.
- **TXT:** consulta rápida, histórico textual e leitura em qualquer editor.
- **HTML:** laudo legível no navegador, inclusive offline, com dados do equipamento, evidências e recomendações.

**Abrir o laudo HTML mais recente:**

Linux (com ambiente gráfico):

```bash
xdg-open "$(find Reports -type f -name relatorio.html | sort | tail -n 1)"
```

Windows (PowerShell):

```powershell
Get-ChildItem .\Reports -Recurse -Filter relatorio.html |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1 |
  ForEach-Object { Start-Process $_.FullName }
```

Os arquivos podem conter **nome do cliente, hostname, IP, logs e número de série**. Revise e anonimiza-os antes de anexar a chamados públicos ou compartilhar com terceiros. Em Linux, a suíte cria relatórios com permissões restritivas; em Windows, aplicam-se as permissões da pasta de destino.

## 7. Estrutura e escolhas de engenharia

```text
OnSiteSuite/
├── onsite.sh                    # entrada da CLI Linux
├── OnSiteSuite.ps1              # entrada da CLI Windows
├── VERSION                      # versão 2.0.1
├── config/
│   ├── tests.json              # catálogo compartilhado
│   └── report.schema.json      # contrato JSON dos laudos
├── src/
│   ├── linux/                 # coletor, execução e inventário Bash
│   ├── windows/               # executor e inventário PowerShell/CIM
│   └── Controllers/, Services/, Models/ ... # base modular legada
├── Config/ e KnowledgeBase/    # regras e fluxos herdados
├── native/                     # coletor auxiliar C++20 (opcional)
├── tests/                      # verificações automatizadas Linux
├── docs/                       # arquitetura, roadmap, segurança e histórico
├── scripts/                    # publicação e manutenção do projeto
└── Reports/                    # saída local; conteúdo ignorado pelo Git
```

**Princípios:** catálogo único de verificações; coleta separada da apresentação; sem obrigatoriedade de OS; estados padronizados; JSON Schema; tratamento explícito de resultados inconclusivos; relatórios locais; aproveitamento da camada de serviços do FieldServiceToolkit.

**Stack:** Bash, PowerShell 7, utilitários nativos do sistema, `jq` e módulo auxiliar **C++20/CMake**. O aplicativo atual é uma **CLI**; a interface gráfica Qt está **no roadmap**, não nesta versão. Não é necessário Docker, Kubernetes, banco de dados nem API externa.

### Compilar o coletor nativo opcional

Se tiver **CMake e compilador compatível com C++20**, execute no Linux:

```bash
cmake -S native -B build/native -DCMAKE_BUILD_TYPE=Release
cmake --build build/native
./build/native/onsite-probe --json
```

### Executar testes de desenvolvimento (Linux)

```bash
bash tests/check-catalog.sh
bash tests/equipment-linux.sh
bash tests/smoke-linux.sh
```

Leia também [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), [`docs/ROADMAP.md`](docs/ROADMAP.md) e [`CHANGELOG.md`](CHANGELOG.md).

## 8. Segurança e privacidade

O uso em campo exige previsibilidade e respeito aos dados do cliente. Por isso, o projeto segue as seguintes decisões:

- **Offline por padrão:** não há telemetria automática; verificações externas de rede exigem `--online` / `-Online`.
- **Coleta não destrutiva:** o fluxo padrão observa informações expostas pelo sistema e grava os relatórios localmente, sem executar reparos ou reinicializações automáticas.
- **Ações físicas explícitas:** imprimir uma página em Linux requer `--print-test` e `--yes-print`; não há execução automática de corte de papel.
- **Privilégios mínimos:** o aplicativo não exige execução integral como administrador/root; leituras indisponíveis são registradas com a limitação correspondente.
- **Evidência com contexto:** ausência de erro em uma sondagem não é certificado de integridade, e informações ausentes não devem ser inventadas.
- **Proteção de dados:** laudos são responsabilidade do operador; evite publicá-los sem remover dados pessoais, identificadores e informações corporativas.

Consulte [`SECURITY.md`](SECURITY.md) e [`docs/SECURITY.md`](docs/SECURITY.md) para orientações e reporte privado de vulnerabilidades. **Use o software somente em equipamentos sob sua responsabilidade ou com autorização.**

## 9. Limitações conhecidas e próximos passos

| Situação | Estado na v2.0.1 |
| --- | --- |
| CLI Linux e testes automatizados de catálogo/inventário | **Executados no ambiente de desenvolvimento** |
| CLI PowerShell para Windows | **Implementada; homologação em hardware real pendente** |
| Identificação e relatórios JSON/TXT/HTML | **Implementados** (coleta depende do sistema) |
| Testes SMART e sensores específicos | **Dependem de hardware, ferramentas e permissões** |
| Teste de impressão Linux/CUPS | **Envio de um job sob consentimento; resultado físico exige verificação** |
| Monitoramento contínuo USB, sequência avançada de impressão, guilhotina | **Planejado** |
| Testes audiovisuais interativos e verificação aprofundada de memória | **Planejados** |
| GUI Qt, histórico local avançado e integração API com ExcelsiorDesk | **Planejados** |

A evolução do produto prioriza procedimentos verificáveis, melhorias de cobertura por plataforma e homologação em cenários reais de Field Service. Veja o [roadmap detalhado](docs/ROADMAP.md).

## 10. Dúvidas frequentes

**Preciso cadastrar uma OS ou cliente?** Não. Execute diretamente pelo menu ou por parâmetro; os dados do atendimento são opcionais.

**Preciso de internet?** Não para as verificações locais e os relatórios. As sondagens externas de rede exigem autorização explícita.

**O programa repara automaticamente o computador?** Não. Ele coleta evidências e apresenta orientações; reparos dependem de decisão técnica e ferramentas apropriadas.

**Por que o número de série ou Service Tag aparece como “Não identificado”?** Alguns equipamentos não expõem esses dados, apresentam valores genéricos de firmware ou restringem o acesso. O OnSiteSuite evita deduzir identificadores não confirmados.

**Por que um teste retorna `INCONCLUSIVO` ou `NAO_SUPORTADO`?** Pode faltar utilitário, permissão, driver, API ou dispositivo compatível. Consulte a evidência e a recomendação correspondente no relatório.

## 11. Como contribuir

Contribuições de técnicos, desenvolvedores, estudantes e entusiastas são bem-vindas, especialmente em suporte multiplataforma, documentação, testes e melhorias de acessibilidade da CLI.

1. Leia [`CONTRIBUTING.md`](CONTRIBUTING.md) e abra uma *issue* descrevendo o problema ou sugestão (sem dados sensíveis).
2. Faça um fork, crie uma branch específica e implemente alterações pequenas e verificáveis.
3. Rode os testes disponíveis, documente limitações e descreva o ambiente em que validou.
4. Abra um *pull request* indicando objetivo, impacto, instruções de teste e eventuais riscos.

O projeto recomenda **Conventional Commits**, por exemplo `feat:`, `fix:`, `docs:` e `test:`. Consulte também [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## 12. Referências, autoria e licença

**Projeto:** OnSiteSuite · **Versão:** `2.0.1`  
**Empresa e identidade do produto:** **Excelsior Soluções em Tecnologia**  
**Desenvolvedor:** **Luís Gazola** · [GitHub @luisgazola](https://github.com/luisgazola)  
**Repositório oficial:** [github.com/luisgazola/OnSiteSuite](https://github.com/luisgazola/OnSiteSuite)

A implementação evoluiu do **FieldServiceToolkit / FieldServiceSuite v1.2.0**, preservando componentes PowerShell e o histórico técnico do repositório. O projeto adota práticas de modularização, separação de responsabilidades, documentação e testes inspiradas em referências clássicas de engenharia de software, como *Arquitetura Limpa* (Robert C. Martin), *Refatoração* (Martin Fowler), *O Programador Pragmático* (Andrew Hunt e David Thomas) e *TDD* (Kent Beck).

O código é disponibilizado sob a **[licença MIT](LICENSE)**, conforme o arquivo oficial do repositório (`Copyright (c) 2026 Luís Gazola`). Consulte a licença para os direitos e condições completos.

---

<div align="center">

**OnSiteSuite v2.0.1 · Diagnósticos mais organizados, evidências rastreáveis e foco no trabalho técnico de campo.**

[Repositório](https://github.com/luisgazola/OnSiteSuite) · [Histórico de alterações](CHANGELOG.md) · [Roadmap](docs/ROADMAP.md) · [Contribuir](CONTRIBUTING.md)

</div>
