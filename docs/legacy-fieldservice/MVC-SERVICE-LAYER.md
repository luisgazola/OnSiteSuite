# MVC + Service Layer

O padrão MVC foi mantido, mas a lógica operacional fica em Services para evitar Controllers grandes.

```text
Controller = fluxo
Service = regra de negócio
Model = dados
View = apresentação
```

Essa divisão é adequada para o FieldServiceSuite porque mantém o projeto simples para uso em campo e organizado para evolução gradual.
