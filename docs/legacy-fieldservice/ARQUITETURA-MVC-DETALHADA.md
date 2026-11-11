# Arquitetura MVC — FieldServiceSuite

## Visão geral

O projeto usa MVC adaptado para PowerShell.

- Model: representa dados do atendimento e diagnóstico.
- View: exibe menus, dashboard e mensagens.
- Controller: coordena o fluxo entre usuário, serviços e modelos.
- Service: executa coletas técnicas, regras, relatórios, logs e configurações.

## Estrutura

```text
FieldServiceSuite
├── Start.ps1
├── App
│   ├── Core
│   ├── Models
│   ├── Views
│   ├── Controllers
│   └── Services
├── Config
├── Reports
├── Logs
├── Docs
└── Tests
```

## Responsabilidades

### Start.ps1

Ponto de entrada do sistema. Carrega o bootstrap e inicia o menu principal.

### App/Core

Inicialização da aplicação, carregamento de módulos e preparação do ambiente.

### App/Models

Estruturas de dados.

Exemplos:

- AtendimentoModel
- DiagnosticModel

### App/Views

Camada visual no terminal.

Exemplos:

- ConsoleView
- DashboardView

### App/Controllers

Controlam fluxos.

Exemplos:

- MainController
- AtendimentoController
- DiagnosticController
- TroubleshootingController

### App/Services

Executam regras e operações técnicas.

Exemplos:

- HardwareService
- StorageService
- BatteryService
- NetworkService
- RulesEngineService
- ReportService

## Regra de dependência

Controllers podem chamar Services e Views.
Services não devem depender de Views.
Models não devem depender de Controllers, Views ou Services.

## Fluxo padrão

```text
Usuário
↓
View
↓
Controller
↓
Service
↓
Model/Resultado
↓
Controller
↓
View/Relatório
```
