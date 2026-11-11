# Diagramas

## Fluxo principal

```mermaid
flowchart TD
    A[Start.ps1] --> B[Bootstrap]
    B --> C[MenuController]
    C --> D[Novo atendimento]
    D --> E[Validação Regex]
    E --> F[Inventário]
    F --> G[Diagnóstico rápido]
    G --> H[RulesEngine]
    H --> I[Recomendações]
    I --> J[Dashboard]
    J --> K[Relatórios HTML/TXT/JSON]
```

## MVC + Service Layer

```mermaid
flowchart LR
    V[Views] --> C[Controllers]
    C --> S[Services]
    S --> M[Models]
    S --> KB[KnowledgeBase JSON]
    S --> WMI[WMI/CIM/Windows]
    C --> R[Reports]
```

## Caso de uso

```mermaid
usecaseDiagram
    actor Tecnico as "Técnico Field Service"
    Tecnico --> (Registrar atendimento)
    Tecnico --> (Executar inventário)
    Tecnico --> (Executar diagnóstico rápido)
    Tecnico --> (Seguir troubleshooting guiado)
    Tecnico --> (Visualizar dashboard)
    Tecnico --> (Gerar relatório)
```
