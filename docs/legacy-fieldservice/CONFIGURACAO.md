# Configuração — FieldServiceSuite

## Arquivos JSON

A configuração fica na pasta `Config`.

```text
Config
├── Reference.json
├── TroubleshootingFlows.json
└── RecommendedActions.json
```

## Reference.json

Define limites técnicos usados para classificar resultados.

Exemplo:

```json
{
  "MemoryUsageWarning": 75,
  "MemoryUsageCritical": 90,
  "DiskFreeWarning": 20,
  "DiskFreeCritical": 10
}
```

## TroubleshootingFlows.json

Define fluxos por sintoma.

Exemplo:

```json
{
  "Notebook lento": [
    "Verificar RAM",
    "Verificar CPU",
    "Verificar Disco/SMART",
    "Verificar drivers",
    "Verificar eventos críticos"
  ]
}
```

## RecommendedActions.json

Define ações recomendadas.

Exemplo:

```json
{
  "HighMemoryUsage": "Verificar processos em segundo plano e considerar upgrade de RAM.",
  "StorageAlert": "Recomendar backup e substituição do disco.",
  "DriverError": "Identificar Hardware ID e reinstalar driver do fabricante."
}
```

## Boas práticas

- Alterar limites no JSON, não no código.
- Manter os nomes das chaves claros.
- Testar após qualquer alteração.
- Evitar regras muito agressivas para não gerar falso positivo em campo.
