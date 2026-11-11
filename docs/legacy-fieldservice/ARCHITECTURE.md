# Arquitetura

O FieldServiceSuite usa **MVC + Service Layer** adaptado para PowerShell.

```text
Start.ps1 -> src/Core/Bootstrap.ps1 -> Controllers -> Services -> Models -> Views
```

## Camadas

- **Core**: inicialização, roteamento, tratamento de erro e carregamento dos módulos.
- **Controllers**: orquestram o fluxo do menu e das ações do técnico.
- **Services**: concentram regras de negócio, coleta de dados, diagnóstico e relatórios.
- **Models**: representam os dados do atendimento, inventário e diagnóstico.
- **Views**: cuidam da apresentação no console e dashboard.
- **Helpers**: funções auxiliares genéricas.
- **Validators**: validações de entrada e consistência.
- **KnowledgeBase**: referências e recomendações em JSON, sem acoplar tudo ao código.
