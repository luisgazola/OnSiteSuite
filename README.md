<div align="center">

# OnSiteSuite

**Diagnóstico, observabilidade USB e validação de impressoras para Field Service.**

Projeto **Excelsior Soluções em Tecnologia** · Desenvolvimento **Luís Gazola**

![Versão](https://img.shields.io/badge/vers%C3%A3o-2.1.0-2563eb)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-16a34a)
![Linux](https://img.shields.io/badge/Linux-testes%20automatizados-16a34a)
![Windows](https://img.shields.io/badge/Windows-homologa%C3%A7%C3%A3o%20pendente-f59e0b)
![Operação](https://img.shields.io/badge/funcionamento-local%20%7C%20offline-475569)

[**Recursos**](#funcionalidades) · [**Linux**](#instalação-no-linux) · [**Windows**](#instalação-no-windows) · [**Monitor USB**](#monitoramento-usb-contínuo) · [**Impressão**](#sequência-avançada-de-impressão) · [**Arquitetura**](#arquitetura) · [**Contribuir**](#contribuindo)

</div>

---

## O projeto

O **OnSiteSuite** é uma suíte de terminal open source para técnicos de campo, assistências, help desks, profissionais de infraestrutura e desenvolvedores. Reúne identificação de equipamentos, diagnósticos selecionáveis, observação de eventos USB, testes de impressão e laudos técnicos locais.

O projeto evolui do **FieldServiceToolkit / FieldServiceSuite** para reduzir tarefas repetitivas em atendimentos: localizar informações de hardware, consultar indicadores, identificar desconexões intermitentes, validar periféricos e documentar a evidência de forma consistente. Uma OS, servidor ou conexão à internet **não são obrigatórios**.

**Fluxo:** identificar o equipamento → selecionar a operação → coletar evidências → registrar resultado → exportar laudo.

### Funcionalidades

- Inventário do **SO, fabricante, modelo, série/Service Tag, tipo de equipamento, CPU, RAM e armazenamento**, quando disponíveis.
- Sondagens de CPU, memória, SMART, bateria, rede, USB, impressoras, drivers, áudio, vídeo, logs e segurança — sempre com limites de medição explícitos.
- **Monitor USB contínuo v2.1.0:** segunda janela de terminal (incluindo `kgx` no GNOME, `PowerShell 7` ou `CMD` no Windows), comparação periódica do inventário USB, eventos de conexão/desconexão com horário, encerramento por `\q` e relatório da sessão.
- **Sequência de impressão v2.1.0:** lotes automáticos de **1, 3, 5 ou 1–100 comprovantes**, numerados e identificados por marca e modelo.
- **Guilhotina opcional ESC/POS:** envia o comando de corte depois de cada comprovante **somente** quando o operador declara compatibilidade e autoriza expressamente o acionamento.
- Relatórios locais **JSON, TXT e HTML**; sessões de USB incluem `usb-eventos.jsonl`; impressão inclui o modelo enviado (`comprovante-impressao.txt`).
- Fluxos de troubleshooting e checklist técnico manual, sem reparos automáticos.

> **Validação:** a suíte de regressão Linux, os eventos USB simulados e os lotes de impressão com spooler simulado foram testados. **Impressão real, corte físico e execução Windows ainda precisam de homologação em equipamentos reais.** O aceite do spooler não comprova a impressão, a comunicação elétrica ou o corte.

## Experiência no terminal

Ao iniciar sem parâmetros, o OnSiteSuite mostra a identificação do equipamento e o menu. Valores ausentes aparecem como **Não identificado**.

```text
======================================================================
 OnSiteSuite v2.1.0 | EXCELSIOR SOLUÇÕES
 Suíte de diagnóstico, troubleshooting e validação de periféricos
 Autoria: Excelsior Soluções em Tecnologia | Desenvolvedor: Luís Gazola
----------------------------------------------------------------------
 IDENTIFICAÇÃO DO EQUIPAMENTO
 SO:                  Linux / Windows
 Número de série:     [lido do firmware ou Não identificado]
 Service Tag:         [quando disponível]
 Marca / Modelo:      [inventário do equipamento]
 Tipo:                Desktop / Notebook / AIO / Não identificado
 CPU / RAM / Discos:  [valores disponíveis]
----------------------------------------------------------------------
 MENU DE TESTES
 1. [x] Identificação do sistema
 2. [x] Processador e temperaturas disponíveis
 ...
 a = Todos passivos | r = Executar | u = Monitor USB | p = Imprimir
 q = Sair
```

**Atalhos:** números alternam testes; `a` seleciona passivos; `r` executa; **`u` abre o monitor em outra janela**; **`p` inicia o assistente de impressão**; `q` sai do menu. Em execução por parâmetros, o menu é dispensado.

## Instalação no Linux

Requisitos: **Bash 5.2+** e **jq 1.7+**. Cliente CUPS (`lp`) necessário apenas para impressão. Para abrir uma segunda janela é necessário um emulador gráfico como **GNOME Console (`kgx`)**; `--foreground` funciona no próprio terminal.

| Distribuição | Instalar `jq` | Cliente CUPS (opcional) |
|---|---|---|
| Debian / Ubuntu | `sudo apt update && sudo apt install -y jq` | `sudo apt install -y cups-client` |
| Fedora | `sudo dnf install -y jq` | `sudo dnf install -y cups-client` |
| Arch Linux | `sudo pacman -S --needed jq` | `sudo pacman -S --needed cups` |
| Gentoo | `sudo emerge -av app-misc/jq` | `sudo emerge -av net-print/cups` |

**Para instalar a versão publicada**, clone a tag `v2.1.0` quando ela estiver disponível no GitHub:

```bash
git clone --branch v2.1.0 --depth 1 https://github.com/luisgazola/OnSiteSuite.git
cd OnSiteSuite
chmod +x onsite.sh
./onsite.sh
```

**Antes da publicação:** utilize o ZIP desta entrega. Extraia `OnSiteSuite-v2.1.0/`, entre na pasta e execute `chmod +x onsite.sh && ./onsite.sh`.

### Uso Linux — diagnósticos

```bash
./onsite.sh --help
./onsite.sh --info                          # identificação sem testes
./onsite.sh --list-tests                    # IDs de sondagens
./onsite.sh --tests system,cpu,memory,usb   # apenas estes testes
./onsite.sh --all                           # sondagens passivas
./onsite.sh --tests network --online        # sondagem externa autorizada
./onsite.sh --tests troubleshooting --symptom sem_internet
```

### Monitoramento USB contínuo

**Abrir em um segundo terminal gráfico (detecção automática):**

```bash
./onsite.sh --usb-monitor
```

O Linux prioriza o **GNOME Console (`kgx`)**, quando instalado, e oferece fallback para `gnome-terminal`, `konsole`, `xfce4-terminal` ou `xterm`.

**Usar obrigatoriamente o GNOME Console (kgx):**

```bash
./onsite.sh --usb-monitor --usb-terminal kgx
```

Se precisar instalar o GNOME Console, utilize o gerenciador de pacotes de sua distribuição (no Gentoo, instale `gui-apps/gnome-console` (comando: `sudo emerge -av gui-apps/gnome-console`)). Também é possível selecionar `--usb-terminal gnome-terminal`, `konsole`, `xfce4-terminal` ou `xterm`. Uma escolha explícita indisponível produz erro, sem mudar silenciosamente de terminal.

Em uma sessão sem ambiente gráfico, ou para acompanhar no terminal atual:

```bash
./onsite.sh --usb-monitor --foreground
```

A aplicação registra as alterações de dispositivos USB identificadas por amostragem (padrão **1 segundo**). **Na janela do monitor, digite `\q` e pressione ENTER**. Isso encerra a coleta, gera o laudo e fecha a janela secundária (quando aberta pelo aplicativo). A janela principal permanece disponível.

```bash
./onsite.sh --usb-monitor --usb-interval 0.5
./onsite.sh --usb-monitor --foreground --usb-interval 2 --output "$HOME/Laudos"
```

Para coleta limitada e testes automatizados: `--usb-monitor --foreground --usb-samples 10` (dez intervalos). O monitor não mede tensão, qualidade de sinal, taxa de erros USB ou perdas mais breves que o intervalo de amostragem.

### Sequência avançada de impressão

**Primeiro configure uma fila CUPS** e verifique o nome exato por `lpstat -a`. O menu **`p`** guia as escolhas de fila, marca, modelo, quantidade e confirmação.

**Imprimir 1, 3, 5 ou uma quantidade digitada (exemplo: 7):**

```bash
./onsite.sh --print-test NOME_DA_FILA --print-count 1 --yes-print
./onsite.sh --print-test NOME_DA_FILA --print-count 3 --yes-print
./onsite.sh --print-test NOME_DA_FILA --print-count 5 --yes-print
./onsite.sh --print-test NOME_DA_FILA --print-count 7 \
  --print-brand Epson --print-model TM-T20 --yes-print
```

O **modo padrão** envia os comprovantes de maneira sequencial para a fila, **sem comandar a guilhotina**. São múltiplas impressões numa mesma operação, não impressoras físicas atuando em paralelo.

**Corte depois de cada impressão (exclusivo para impressora comprovadamente compatível com RAW ESC/POS):**

```bash
./onsite.sh --print-test NOME_DA_FILA --print-count 5 \
  --print-brand Epson --print-model TM-T20 \
  --escpos-raw --cut-after-each --cut-mode full \
  --yes-print --yes-cut
```

O modo RAW envia **um job com cinco comprovantes e cinco comandos de corte `GS V 0`** após cada comprovante. `--cut-mode partial` usa `GS V 1`. Essas variantes dependem do modelo e firmware. Algumas filas CUPS filtram ou rejeitam RAW. Se houver dúvida, **não use o corte**; consulte o manual ESC/POS da impressora, a configuração da fila e o comportamento do modelo.

**Proteções:** sem `--yes-print` nenhum papel é enviado; sem `--escpos-raw --cut-after-each --yes-cut` nenhum comando de guilhotina é gerado; o lote é limitado a **100 comprovantes**. O resultado da fila é registrado como `INCONCLUSIVO` até conferência física.

Modelo resumido de cada comprovante:

```text
OnSiteSuite
Equipamento: Impressora
Marca: [fabricante]
Modelo: [modelo]
Quantidade de impressões de teste: 5

Impressão Número: 1

Lorem ipsum dolor sit amet, consectetur...

Desenvolvedor: Luís Gazola
Empresa: Excelsior Soluções em Tecnologia
----------------------------------------
----------------------------------------
[corte físico, apenas se compatível e autorizado]
[próxima impressão numerada]
```

## Instalação no Windows

**Alvo:** Windows 10/11 com **PowerShell 7.4.6**. Os scripts Windows ainda não foram executados em hardware real nesta entrega. Não presuma compatibilidade com Windows PowerShell 5.1.

Após obter o ZIP de `v2.1.0`, você pode iniciar a mesma aplicação pelo **PowerShell 7** ou pelo **Prompt de Comando (CMD)**. O CMD funciona como interface; o motor de diagnóstico continua sendo o **PowerShell 7.4.6** (`pwsh.exe`) e deve estar instalado e disponível no PATH.

**PowerShell 7:**

```powershell
pwsh --version
.\OnSiteSuite.ps1
.\OnSiteSuite.ps1 -InfoOnly
.\OnSiteSuite.ps1 -ListTests
.\OnSiteSuite.ps1 -Tests 'system,cpu,memory,usb' -NonInteractive
```

**CMD (`cmd.exe`):**

```bat
pwsh --version
OnSiteSuite.cmd
OnSiteSuite.cmd -InfoOnly
OnSiteSuite.cmd -ListTests
OnSiteSuite.cmd -Tests system,cpu,memory,usb -NonInteractive
```

O arquivo `OnSiteSuite.cmd` vem na raiz do projeto e chama `pwsh.exe -NoProfile -File OnSiteSuite.ps1`. Ele não depende de `powershell.exe` 5.1 nem modifica a política de execução do sistema. Se a política local bloquear o arquivo `.ps1`, siga a política de TI da organização; não é feita alteração automática de política.

Para obter a versão via Git após publicação:

```powershell
git clone --branch v2.1.0 --depth 1 https://github.com/luisgazola/OnSiteSuite.git
Set-Location .\OnSiteSuite
.\OnSiteSuite.ps1
```

### Monitor USB em nova janela no Windows

**PowerShell 7 como terminal secundário (padrão):**

```powershell
.\OnSiteSuite.ps1 -UsbMonitor
.\OnSiteSuite.ps1 -UsbMonitor -UsbTerminal PowerShell
```

**CMD como terminal secundário, solicitado do PowerShell:**

```powershell
.\OnSiteSuite.ps1 -UsbMonitor -UsbTerminal CMD
```

**Dentro do próprio Prompt de Comando:**

```bat
OnSiteSuite.cmd -UsbMonitor
OnSiteSuite.cmd -UsbMonitor -UsbTerminal PowerShell
OnSiteSuite.cmd -UsbMonitor -UsbTerminal CMD
```

Ao iniciar por `OnSiteSuite.cmd`, o modo `Auto` escolhe o CMD; com `OnSiteSuite.ps1`, escolhe o PowerShell. `-UsbTerminal` sempre tem prioridade sobre essa escolha. As duas opções geram os mesmos relatórios.

A segunda janela observa a enumeração PnP USB. **Digite `\q` na janela de monitor** para finalizar e salvar os relatórios; no Windows não é necessário pressionar ENTER. Para medições com fim automático em ambiente de teste, utilize `-UsbSamples 10 -UsbInterval 1`.

### Sequência de impressão no Windows

```powershell
# Lote de três impressões; não envia corte.
.\OnSiteSuite.ps1 -PrintQueue 'Minha Impressora' -PrintCount 3 -YesPrint

# Somente para fila e impressora compatíveis com RAW ESC/POS e guilhotina.
.\OnSiteSuite.ps1 -PrintQueue 'Minha Impressora' -PrintCount 5 `
  -PrintBrand 'Epson' -PrintModel 'TM-T20' `
  -EscPosRaw -CutAfterEach -CutMode full -YesPrint -YesCut
```

O modo padrão utiliza o spooler Windows (`Out-Printer`). O modo RAW utiliza a API WinSpool, compila um pequeno adaptador C# localmente e entrega os comandos ESC/POS. **O driver, a fila e a impressora precisam aceitar dados RAW; nenhum resultado físico foi homologado nesta entrega.**

## Relatórios

Cada sessão de diagnóstico gera os arquivos no diretório `Reports/AAAA/MM/DD/<sessão>/` (ou no diretório passado por `--output` / `-Output`):

| Arquivo | Conteúdo |
|---|---|
| `relatorio.json` | Metadados, inventário, estados, horários, evidências e recomendações. |
| `relatorio.txt` | Versão legível para chamados e registros rápidos. |
| `relatorio.html` | Laudo local para navegador e impressão. |
| `usb-eventos.jsonl` | **Apenas monitor USB:** registro completo de início, conexão, desconexão e encerramento com timestamp. |
| `comprovante-impressao.txt` | **Apenas lote de impressão:** modelo numerado enviado ao spooler. |

O contrato JSON permanece em **`schemaVersion: "2.0"`** para preservar a compatibilidade das integrações; a versão executável agora é **`2.1.0`**.

**Estados:** `OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO`, `NAO_SUPORTADO`. O resultado `INCONCLUSIVO` é adequado quando a fila aceita um job sem evidência de impressão física. Conexão/desconexão observada **não confirma** defeito de cabo, porta, controlador ou impressora.

**Abrir o HTML mais recente:**

```bash
# Linux
xdg-open "$(find Reports -type f -name relatorio.html | sort | tail -n 1)"
```

```powershell
# Windows PowerShell 7
Get-ChildItem .\Reports -Recurse -Filter relatorio.html |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1 |
  ForEach-Object { Start-Process $_.FullName }
```

## Arquitetura

A v2.1.0 preserva o **MVC + Service Layer** consolidado na v2.0.3 e adiciona componentes especializados:

```text
OnSiteSuite/
├── onsite.sh / OnSiteSuite.ps1 / OnSiteSuite.cmd # entradas Linux, PowerShell e CMD
├── VERSION / config/             # versão, catálogo e schema JSON 2.0
├── src/
│   ├── linux/
│   │   ├── App/ Controllers/ Domain/ Views/
│   │   ├── Services/              # Diagnostic, Report, UsbMonitor, Print
│   │   └── Adapters/              # Probe, Equipment, USB, impressão, Terminal (kgx)
│   └── windows/
│       ├── App/ Controllers/ Domain/ Views/
│       ├── Services/              # Diagnostic, Report, UsbMonitor, Print
│       └── Adapters/              # CIM, USB, WinSpool RAW e Terminal (CMD/PowerShell)
├── tests/                         # regressão Linux e testes Windows mockados
├── docs/                          # decisões, segurança e roadmap
├── scripts/publish-github.sh
└── Reports/                       # relatórios locais (ignorados no Git)
```

Os **Controllers** administram a sessão; as **Views** apresentam menus e recebem confirmações; os **Services** executam os casos de uso; os **Adapters** interagem com sysfs/CUPS no Linux e CIM/WinSpool no Windows; o **Domain** padroniza os resultados. Os serviços de impressão não enviam papel sem autorização do técnico.

Detalhes em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) e no histórico da consolidação em [`docs/CLEANUP_2.0.3.md`](docs/CLEANUP_2.0.3.md).

## Testes e qualidade

```bash
# Regressão Linux completa, inclusive USB e impressão simulados
bash tests/run-linux.sh
```

No Windows, quando houver PowerShell 7:

```powershell
pwsh -NoProfile -File ./tests/architecture-windows.ps1
pwsh -NoProfile -File ./tests/adapters-windows.ps1
pwsh -NoProfile -File ./tests/advanced-windows.ps1
pwsh -NoProfile -File ./tests/terminal-windows.ps1
```

O teste `terminal-windows.ps1` valida os argumentos preparados para CMD/PowerShell sem abrir janelas; a execução real no Windows permanece pendente. Os testes com fila CUPS simulada **não enviam papel real**. Os testes de WinSpool/RAW no Windows também dependem de validação em máquina real e impressora compatível.

## Segurança e limitações

- **Consentimento explícito:** impressão requer `--yes-print`/`-YesPrint`; corte requer também modo RAW e `--yes-cut`/`-YesCut`.
- **Privilégio mínimo:** monitor USB e diagnóstico não elevam permissões automaticamente. Não rode a suíte toda como `root`/Administrador apenas para forçar a leitura de um recurso.
- **Offline por padrão:** sem telemetria ou rede externa automática. Sondagens externas de rede exigem `--online`/`-Online`.
- **Privacidade:** identificadores PnP/USB, serial, hostname, cliente e logs podem ser sensíveis. Revise relatórios antes de compartilhar; a responsabilidade por retenção e LGPD é do operador.
- **Terminais Windows:** CMD é um host de terminal para o motor `pwsh.exe` 7; não se afirma suporte a execução nativa dos scripts sob `cmd.exe` nem sob `powershell.exe` 5.1.
- **Monitor USB por amostragem:** pode perder eventos rápidos entre leituras. Não mede estabilidade elétrica, sinal, velocidades ou integridade de cabo.
- **ESC/POS varia entre fabricantes:** **não** assuma que todo modelo térmico ou toda fila de impressão suporta guilhotina. O comando `GS V` pode não funcionar ou produzir efeito diferente dependendo do firmware.
- **Sem prova de impressão física:** aceitar o job no spooler não confirma papel, alinhamento, tinta, comunicação ou corte.
- **Escopo:** ferramentas complementares de diagnóstico; não são certificação, correção automática ou auditoria de segurança completa.

Consulte [`SECURITY.md`](SECURITY.md) e [`docs/SECURITY.md`](docs/SECURITY.md). Use apenas em equipamentos sob sua responsabilidade ou com autorização.

## Publicação no GitHub

O projeto usa o histórico do repositório [luisgazola/OnSiteSuite](https://github.com/luisgazola/OnSiteSuite), renomeado do FieldServiceToolkit.

Para publicar a **v2.1.0** depois de revisar o código, configure autenticação Git e identidade do autor. Na pasta extraída, execute:

```bash
bash scripts/publish-github.sh
```

O script executa os testes Linux, clona a branch `main` em nova pasta, aplica a nova versão e cria **uma nova tag `v2.1.0`**, sem sobrescrever as tags anteriores. A publicação exige permissão de escrita no GitHub.

## Contribuindo

Contribuições em compatibilidade ESC/POS, drivers, simuladores, integração Windows, telemetria **local e opcional**, acessibilidade de terminal e cobertura de testes são bem-vindas. Abra uma issue sem dados pessoais, crie uma branch, rode os testes e envie um pull request com evidências e limitações. Veja [`CONTRIBUTING.md`](CONTRIBUTING.md) e [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## Referências e licença

**Projeto:** OnSiteSuite · **Versão:** 2.1.0  
**Empresa:** **Excelsior Soluções em Tecnologia**  
**Desenvolvedor:** **Luís Gazola** · [@luisgazola](https://github.com/luisgazola)  
**Código-fonte:** [github.com/luisgazola/OnSiteSuite](https://github.com/luisgazola/OnSiteSuite)

Licença **[MIT](LICENSE)**. Projeto derivado e evoluído do FieldServiceToolkit com histórico Git preservado. A separação de camadas e a estratégia de testes seguem práticas consolidadas de arquitetura limpa, refatoração, TDD e programação pragmática. Para detalhes, consulte [`CHANGELOG.md`](CHANGELOG.md), [`docs/ROADMAP.md`](docs/ROADMAP.md) e [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

<div align="center">**OnSiteSuite v2.1.0 — Field Service orientado a evidências, integração simples e execução sob controle do técnico.**</div>
