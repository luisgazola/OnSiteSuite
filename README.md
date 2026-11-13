<div align="center">

# OnSiteSuite

### Diagnóstico, troubleshooting e automação técnica para Field Service e suporte de TI

**Uma suíte open source e multiplataforma para investigar problemas, organizar procedimentos e documentar evidências técnicas.**

**Projeto pessoal de Luís Fernando Gazola**, integrado ao ecossistema de iniciativas da **Excelsior Soluções em Tecnologia**

[![Versão](https://img.shields.io/badge/vers%C3%A3o-2.2.0-2563eb)](CHANGELOG.md)
[![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-16a34a)](LICENSE)
![Plataformas](https://img.shields.io/badge/plataformas-Windows%20%7C%20Linux-475569)
![Tecnologias](https://img.shields.io/badge/PowerShell%207-%2B%20Bash-7c3aed)
![Operação](https://img.shields.io/badge/execu%C3%A7%C3%A3o-local%20%7C%20offline-0891b2)

[Visão geral](#visão-geral) · [Aplicações](#onde-o-onsitesuite-é-útil) · [Recursos](#o-que-o-projeto-oferece) · [Instalação](#comece-a-usar) · [Arquitetura](#arquitetura-e-tecnologias) · [Contribuir](#contribua-com-o-projeto)

**[Repositório](https://github.com/luisgazola/OnSiteSuite)** · **[Versões](https://github.com/luisgazola/OnSiteSuite/tags)** · **[Evolução do projeto](docs/ROADMAP.md)**

</div>

---

## Visão geral

O **OnSiteSuite** é um projeto autoral de software voltado à **operação e ao diagnóstico técnico de computadores, sistemas operacionais e periféricos**. Foi criado para apoiar profissionais que precisam investigar incidentes, verificar o estado de equipamentos, executar procedimentos de troubleshooting e produzir registros claros do trabalho realizado.

A ferramenta reúne em um único fluxo tarefas frequentemente espalhadas por comandos do sistema, utilitários de fabricantes e anotações manuais. Pode ser utilizada em atendimentos presenciais, bancadas de manutenção, laboratórios, help desks e atividades de suporte à infraestrutura.

Seu objetivo é **reduzir atividades repetitivas, melhorar a consistência dos diagnósticos e facilitar a coleta de evidências**, mantendo o técnico responsável pela interpretação e pelas decisões.

O projeto surgiu da experiência prática de **Luís Fernando Gazola** com Field Service e evoluiu do **FieldServiceToolkit**. É mantido como iniciativa pessoal e faz parte do ecossistema de projetos da **Excelsior Soluções em Tecnologia**. O funcionamento do OnSiteSuite é independente: **não exige ExcelsiorDesk, servidor, conta, banco de dados nem conexão à internet**. Integrações entre produtos são possibilidades de evolução, não requisitos da versão atual.

### Princípios do projeto

- **Utilidade em campo:** comandos objetivos e seleção de testes conforme o problema.
- **Diagnóstico responsável:** distinguir medições, observações, hipóteses e limitações.
- **Offline por padrão:** execução e geração de relatórios no equipamento local.
- **Multiplataforma:** experiência equivalente em Windows e Linux, respeitando as APIs de cada sistema.
- **Modularidade:** recursos organizados em camadas para facilitar testes e manutenção.
- **Evidências portáveis:** arquivos estruturados que podem acompanhar atendimentos e análises futuras.
- **Software aberto:** código acessível para estudo, auditoria e colaboração sob a licença MIT.

## Onde o OnSiteSuite é útil

| Cenário | Aplicação prática |
|---|---|
| **Field Service e suporte presencial** | Identificar o equipamento, selecionar verificações e registrar o atendimento. |
| **Help Desk e troubleshooting** | Investigar sintomas de lentidão, rede, bateria, armazenamento, drivers e periféricos. |
| **Assistência técnica e bancada** | Repetir procedimentos de inspeção e comparar evidências entre sessões. |
| **Infraestrutura e suporte corporativo** | Consultar indicadores locais de sistema, hardware, serviços e eventos. |
| **Periféricos e dispositivos USB** | Observar conexões, desconexões e reconexões durante um teste controlado. |
| **Desenvolvimento e aprendizado** | Estudar automação multiplataforma, arquitetura modular, testes e geração de relatórios. |

## O que o projeto oferece

As funcionalidades atuais estão agrupadas por **capacidade técnica**, e não por um único tipo de equipamento.

| Área | Capacidades disponíveis na v2.2.0 |
|---|---|
| **Inventário e contexto** | Sistema operacional, fabricante, modelo, número de série/Service Tag quando disponíveis, CPU, memória e armazenamento. |
| **Hardware e saúde do sistema** | Sondagens de processador, memória, unidades de armazenamento, SMART opcional e bateria; dependem das informações expostas pelo equipamento. |
| **Sistema operacional e infraestrutura** | Inspeção de rede, dispositivos, drivers, logs e indicadores locais de segurança. |
| **Periféricos** | Identificação de USB, impressoras, áudio e monitores; certos testes são apenas de enumeração, sem validação física completa. |
| **Monitoramento e observabilidade** | Sessões de observação USB, eventos cronológicos, estatísticas por dispositivo e comparação opcional entre sessões. |
| **Troubleshooting orientado** | Fluxos por sintoma e checklist físico supervisionado, sem reparos automáticos. |
| **Validação de impressão** | Comprovantes numerados e envio ao spooler; corte ESC/POS opcional apenas com compatibilidade declarada e autorização explícita. |
| **Documentação técnica** | Relatórios JSON, TXT e HTML, além de arquivos específicos de evidência quando aplicáveis. |

> **Limites importantes:** uma sondagem não equivale a um teste laboratorial completo. Identificar uma impressora não comprova impressão física; listar um dispositivo de áudio não comprova reprodução; observar uma desconexão USB não identifica automaticamente o componente defeituoso. Os relatórios preservam essas distinções.

### Como funciona

```text
Abrir o OnSiteSuite
        │
        ▼
Identificar o equipamento e o ambiente
        │
        ▼
Selecionar diagnóstico, monitoramento ou procedimento
        │
        ▼
Coletar informações e evidências locais
        │
        ▼
Revisar os resultados e as limitações
        │
        ▼
Gerar relatórios e registrar conclusões do atendimento
```

O usuário pode operar pelo **menu interativo** ou por **parâmetros de linha de comando**, úteis para repetição de testes e automação autorizada. A criação de uma ordem de serviço é opcional.

## Comece a usar

### Requisitos

| Plataforma | Requisitos principais |
|---|---|
| **Linux** | Bash **5.2+**, `jq` **1.7+**; ferramentas de diagnóstico adicionais conforme o módulo escolhido. |
| **Windows 10/11** | **PowerShell 7** (`pwsh.exe`); a versão de referência do projeto é **7.4.6**. Também há lançador para CMD. |

O projeto não requer Docker, Kubernetes, serviço web, instalação de banco de dados ou privilégios administrativos para iniciar. Determinadas leituras de hardware podem exigir permissões específicas.

### 1. Baixar o código

**Com Git, usando a versão específica 2.2.0:**

```bash
git clone --branch v2.2.0 --depth 1 https://github.com/luisgazola/OnSiteSuite.git
cd OnSiteSuite
```

Outra opção é baixar o arquivo ZIP da versão no [repositório GitHub](https://github.com/luisgazola/OnSiteSuite/tags) e extrair os arquivos em uma pasta de sua preferência.

### 2. Linux — Debian/Ubuntu, Fedora, Arch Linux e Gentoo

Instale a dependência básica `jq` usando **somente o comando da sua distribuição**:

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y jq

# Fedora
sudo dnf install -y jq

# Arch Linux
sudo pacman -S --needed jq

# Gentoo
sudo emerge -av app-misc/jq
```

Na pasta do projeto:

```bash
chmod +x onsite.sh
./onsite.sh                          # menu interativo
./onsite.sh --info                   # identificação do equipamento
./onsite.sh --list-tests             # catálogo de testes
./onsite.sh --tests system,cpu,memory,storage
./onsite.sh --all                    # sondagens passivas
```

Para diagnosticar um sintoma ou executar um monitoramento supervisionado:

```bash
./onsite.sh --tests troubleshooting --symptom sem_internet
./onsite.sh --usb-monitor            # monitor USB em segundo terminal
./onsite.sh --usb-monitor --foreground  # monitor no terminal atual
```

No Gentoo com GNOME Console, é possível selecionar o terminal `kgx`:

```bash
./onsite.sh --usb-monitor --usb-terminal kgx
```

No monitor USB Linux, digite **`\q` e ENTER** para encerrar e salvar as evidências. O programa usa `kgx -- bash ...` para abrir a janela quando esse terminal é escolhido.

### 3. Windows — PowerShell 7 e CMD

Abra o terminal na pasta do projeto e confirme que `pwsh.exe` está disponível.

**PowerShell 7:**

```powershell
pwsh --version
.\OnSiteSuite.ps1
.\OnSiteSuite.ps1 -InfoOnly
.\OnSiteSuite.ps1 -ListTests
.\OnSiteSuite.ps1 -Tests 'system,cpu,memory,storage' -NonInteractive
.\OnSiteSuite.ps1 -UsbMonitor -UsbTerminal PowerShell
```

**Prompt de Comando (CMD):**

```bat
pwsh --version
OnSiteSuite.cmd
OnSiteSuite.cmd -InfoOnly
OnSiteSuite.cmd -ListTests
OnSiteSuite.cmd -UsbMonitor -UsbTerminal CMD
```

O **CMD funciona como lançador**: o motor de diagnósticos continua sendo o PowerShell 7. A aplicação não modifica automaticamente políticas de execução nem solicita elevação de privilégios.

### Atalhos do menu

| Atalho | Ação |
|---|---|
| **Números** | Alternar os testes desejados. |
| `a` | Selecionar todas as sondagens passivas. |
| `r` | Executar a seleção. |
| `u` | Iniciar monitoramento USB em outra janela. |
| `p` | Abrir o assistente de testes de impressão. |
| `q` | Sair do menu principal. |

Para consultar outras opções disponíveis, use `./onsite.sh --help` no Linux ou `Get-Help .\OnSiteSuite.ps1` no PowerShell.

## Módulos e procedimentos especializados

O OnSiteSuite foi planejado como uma suíte extensível. Alguns recursos exigem comandos próprios e dependências opcionais:

- **Monitoramento e análise USB:** eventos de conexão/desconexão, contagem de reconexões, `usb-resumo.json` e comparação com sessões anteriores via `--usb-baseline` (Linux) ou `-UsbBaseline` (Windows).
- **Testes de impressão:** lotes de comprovantes com quantidade configurável, mediante autorização; no Linux, requer fila de impressão CUPS para o envio convencional.
- **Guilhotina ESC/POS:** opcional e restrita a dispositivos e filas compatíveis com RAW; requer confirmação específica do técnico. O aceite de um trabalho pela fila não garante corte ou impressão física.
- **Troubleshooting por sintomas:** orientações e verificações que podem complementar o diagnóstico, sem executar reparos automaticamente.

Exemplos de comandos especializados:

```bash
# Linux: comparar uma sessão USB com uma referência anterior
./onsite.sh --usb-monitor --usb-baseline '/caminho/usb-resumo.json'

# Linux: imprimir um único comprovante, sem comando de corte
./onsite.sh --print-test NOME_DA_FILA --print-count 1 --yes-print
```

```powershell
# Windows: monitor com comparação de referência
.\OnSiteSuite.ps1 -UsbMonitor -UsbBaseline 'C:\Laudos\usb-resumo.json'

# Windows: enviar um comprovante para uma impressora configurada
.\OnSiteSuite.ps1 -PrintQueue 'Minha Impressora' -PrintCount 1 -YesPrint
```

Para instruções detalhadas, parâmetros, cuidados de impressão e limites técnicos, consulte as [notas da v2.1.0](docs/RELEASE_2.1.0.md) e as [notas da v2.2.0](docs/RELEASE_2.2.0.md).

## Relatórios e evidências

Cada execução pode produzir relatórios locais em `Reports/AAAA/MM/DD/<sessão>/` ou no diretório de saída escolhido pelo operador.

| Arquivo | Utilização |
|---|---|
| `relatorio.json` | Registro estruturado para consulta, arquivamento e possíveis integrações. |
| `relatorio.txt` | Resumo legível e fácil de anexar a um chamado. |
| `relatorio.html` | Visualização do laudo em navegador local. |
| `usb-eventos.jsonl` | Histórico de eventos quando o monitor USB é executado. |
| `usb-resumo.json` | Estatísticas por dispositivo em sessões de diagnóstico USB. |
| `usb-comparacao.json` | Diferenças observadas quando há uma sessão-base informada. |
| `comprovante-impressao.txt` | Modelo de comprovante associado aos testes de impressão. |

O contrato principal permanece em **`schemaVersion: "2.0"`**, enquanto a versão do aplicativo é **2.2.0**. Os resultados usam estados padronizados: `OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO` e `NAO_SUPORTADO`.

**Atenção à privacidade:** os laudos podem conter número de série, nomes de equipamentos, dados de rede e identificação de dispositivos. Revise o conteúdo antes de compartilhar e aplique as regras de proteção de dados da organização.

## Arquitetura e tecnologias

O projeto adota **MVC adaptado à interface de terminal + Service Layer**, com separação entre coordenação, apresentação, regras de aplicação, contratos e acesso ao sistema operacional.

```text
OnSiteSuite
├── Entradas: onsite.sh | OnSiteSuite.ps1 | OnSiteSuite.cmd
├── Controllers / Views     → fluxo de sessão e interface
├── Services                → diagnósticos, monitoramento, relatórios
├── Domain                  → contratos, estados e validações
├── Adapters                → Linux (/proc, /sys, CUPS) e Windows (CIM, WinSpool)
├── config/                 → catálogo, fluxos orientativos, schema JSON
├── tests/                  → regressão e testes de serviços/adaptadores
└── docs/                   → arquitetura, evolução, segurança e releases
```

**Tecnologias principais:** PowerShell 7, Bash, JSON, ferramentas nativas dos sistemas operacionais e C# restrito ao adaptador RAW de impressão no Windows. A execução normal é local e não depende de uma API externa.

A arquitetura foi concebida para permitir evolução por módulos e automação de testes, sem impor microserviços ou dependências desnecessárias. Veja [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Qualidade, status e limitações

- **Linux:** testes de regressão automatizados, análises USB e impressão simulada executados no desenvolvimento da v2.2.0.
- **Windows:** funcionamento prático da linha **2.1.0** confirmado pelo mantenedor; os módulos novos de análise USB da **2.2.0** precisam de validação própria em ambiente Windows.
- **Equipamentos e periféricos:** resultados variam conforme permissões, firmware, drivers e suporte a protocolos. Impressão física e guilhotina não são consideradas homologadas apenas por testes simulados.
- **Segurança operacional:** as coletas são predominantemente passivas. Rede externa e operações físicas, como impressão e corte, exigem opções explícitas.
- **Escopo:** o OnSiteSuite não substitui equipamentos de medição, ferramentas oficiais de fabricantes, perícia ou certificação de hardware.

Para verificar o código após baixá-lo:

```bash
# Linux
bash tests/run-linux.sh
```

```powershell
# Windows — PowerShell 7
pwsh -NoProfile -File .\tests\run-windows.ps1
```

A execução e o resultado dos testes em sua máquina devem ser registrados separadamente dos resultados simulados. Consulte [validação da v2.2.0](docs/VALIDATION_2.2.0.md), [`CHANGELOG.md`](CHANGELOG.md) e [`SECURITY.md`](SECURITY.md).

## Evolução do projeto

O desenvolvimento segue um roadmap incremental: melhoria dos diagnósticos, observabilidade de dispositivos, laboratório de periféricos, histórico e comparação de laudos, experiência de terminal, qualidade e distribuição. Uma interface gráfica e integrações opcionais com sistemas de atendimento são possibilidades futuras.

As funcionalidades planejadas **não devem ser confundidas com recursos já implementados**. Consulte [`docs/ROADMAP.md`](docs/ROADMAP.md) e as [issues do repositório](https://github.com/luisgazola/OnSiteSuite/issues).

## Contribua com o projeto

O OnSiteSuite também é um espaço de colaboração e aprendizado em engenharia de software aplicada a problemas reais de TI.

São bem-vindas contribuições em compatibilidade de hardware, testes Windows/Linux, diagnósticos, acessibilidade, documentação, manutenção de adaptadores, novos fluxos de troubleshooting e revisão de segurança.

Para contribuir, abra uma [issue](https://github.com/luisgazola/OnSiteSuite/issues) com o cenário e os resultados observados, ou proponha alterações por pull request. Não publique números de série, identificadores de clientes, logs sensíveis ou credenciais. Leia [`CONTRIBUTING.md`](CONTRIBUTING.md), [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) e [`SECURITY.md`](SECURITY.md).

## Autoria, referências e licença

**OnSiteSuite** é um **projeto pessoal de Luís Fernando Gazola**, derivado e evoluído do FieldServiceToolkit. Faz parte do ecossistema de iniciativas da **Excelsior Soluções em Tecnologia**, preservando sua identidade autoral e sua operação independente.

- **Autor e mantenedor:** [Luís Fernando Gazola](https://github.com/luisgazola)
- **Repositório oficial:** [luisgazola/OnSiteSuite](https://github.com/luisgazola/OnSiteSuite)
- **Licença do código:** [MIT](LICENSE)
- **Documentação técnica:** [`docs/`](docs/ARCHITECTURE.md), [`CHANGELOG.md`](CHANGELOG.md) e [`docs/ROADMAP.md`](docs/ROADMAP.md)

O projeto aplica princípios de código limpo, responsabilidade única, refatoração, testes de regressão e arquitetura em camadas. A documentação registra as decisões e limitações existentes; não implica certificação formal dos equipamentos diagnosticados.

---

<div align="center">

**OnSiteSuite — Diagnósticos mais consistentes. Evidências mais claras. Suporte técnico mais eficiente.**

*Desenvolvido por Luís Fernando Gazola · Ecossistema Excelsior Soluções em Tecnologia*

</div>
