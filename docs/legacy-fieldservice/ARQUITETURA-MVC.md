# Arquitetura MVC do FieldServiceSuite

## Fluxo

```text
Start.ps1
↓
Bootstrap
↓
MainController
↓
Views para interação
↓
Controllers para fluxo
↓
Services para coleta e regra de negócio
↓
Models para padronizar dados
↓
Reports
```

## Responsabilidades

### Controllers
Recebem a ação do técnico e coordenam o fluxo.

### Views
Exibem menus, mensagens, dashboard e informações ao técnico.

### Models
Padronizam os objetos de atendimento e diagnóstico.

### Services
Executam a lógica real: hardware, rede, disco, bateria, drivers, regras, recomendações e relatórios.
