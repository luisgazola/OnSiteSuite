# Fluxogramas e Diagramas — FieldServiceSuite

## Fluxograma principal

```mermaid
flowchart TD
    A[Iniciar Start.ps1] --> B[Carregar Bootstrap]
    B --> C[Carregar Config JSON]
    C --> D[Exibir Menu]
    D --> E{Opção}

    E -->|Novo Atendimento| F[Coletar dados]
    F --> G[Validar Regex]
    G --> H{Dados válidos?}
    H -->|Não| F
    H -->|Sim| I[Criar contexto do atendimento]

    E -->|Inventário| J[Coletar hardware]
    E -->|Diagnóstico Rápido| K[Executar módulos]
    E -->|Troubleshooting| L[Selecionar fluxo por sintoma]
    E -->|Dashboard| M[Renderizar dashboard]
    E -->|Relatório| N[Gerar HTML TXT JSON]
    E -->|Sair| O[Encerrar]

    J --> P[Atualizar contexto]
    K --> P
    L --> P
    P --> Q[Classificar resultados]
    Q --> R[Gerar recomendações]
    R --> M
    M --> D
    N --> D
```

## Caso de uso

```mermaid
usecaseDiagram
    actor Tecnico as "Técnico Field Service"

    Tecnico --> (Registrar atendimento)
    Tecnico --> (Executar inventário)
    Tecnico --> (Executar diagnóstico rápido)
    Tecnico --> (Seguir troubleshooting guiado)
    Tecnico --> (Preencher checklist)
    Tecnico --> (Visualizar dashboard)
    Tecnico --> (Gerar relatório)

    (Registrar atendimento) --> (Validar dados com Regex)
    (Executar diagnóstico rápido) --> (Classificar OK Atenção Crítico)
    (Seguir troubleshooting guiado) --> (Consultar fluxos JSON)
    (Classificar OK Atenção Crítico) --> (Gerar recomendações)
    (Gerar relatório) --> (Exportar HTML)
    (Gerar relatório) --> (Exportar TXT)
    (Gerar relatório) --> (Exportar JSON)
```

## Diagrama de módulos

```mermaid
classDiagram
    class Start {
        +Main()
    }

    class MainController {
        +ShowMainMenu()
        +HandleOption()
    }

    class AtendimentoController {
        +NewAtendimento()
    }

    class DiagnosticController {
        +RunQuickDiagnostic()
    }

    class TroubleshootingController {
        +StartGuidedTroubleshooting()
    }

    class ConsoleView {
        +WriteHeader()
        +WriteMenu()
        +WriteStatus()
    }

    class DashboardView {
        +ShowDashboard()
    }

    class HardwareService
    class StorageService
    class BatteryService
    class NetworkService
    class DriverService
    class RulesEngineService
    class RecommendationService
    class ReportService
    class LoggingService

    Start --> MainController
    MainController --> AtendimentoController
    MainController --> DiagnosticController
    MainController --> TroubleshootingController
    MainController --> DashboardView
    MainController --> ReportService

    DiagnosticController --> HardwareService
    DiagnosticController --> StorageService
    DiagnosticController --> BatteryService
    DiagnosticController --> NetworkService
    DiagnosticController --> DriverService
    DiagnosticController --> RulesEngineService
    RulesEngineService --> RecommendationService
    ReportService --> LoggingService
```

## Sequência do atendimento

```mermaid
sequenceDiagram
    actor Tecnico
    participant Start
    participant MainController
    participant AtendimentoController
    participant DiagnosticController
    participant RulesEngine
    participant Dashboard
    participant Report

    Tecnico->>Start: Executa Start.ps1
    Start->>MainController: Inicia menu
    Tecnico->>MainController: Novo atendimento
    MainController->>AtendimentoController: Coletar dados
    AtendimentoController-->>MainController: Atendimento válido
    Tecnico->>MainController: Diagnóstico rápido
    MainController->>DiagnosticController: Executar diagnóstico
    DiagnosticController->>RulesEngine: Classificar evidências
    RulesEngine-->>DiagnosticController: Status e recomendações
    Tecnico->>MainController: Dashboard
    MainController->>Dashboard: Exibir resumo
    Tecnico->>MainController: Gerar relatório
    MainController->>Report: Exportar HTML TXT JSON
```
