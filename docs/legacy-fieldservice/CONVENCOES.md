# Convenções do Projeto

## Nome de arquivos

- Controllers: `NomeController.psm1`
- Services: `NomeService.psm1`
- Views: `NomeView.psm1`
- Models: `NomeModel.psm1`

## Nome de funções

Usar verbo aprovado do PowerShell sempre que possível.

Exemplos:

```powershell
Get-HardwareInventory
New-FieldServiceSession
Show-MainMenu
Export-FieldServiceReport
Test-NetworkHealth
```

## Commits

Usar Conventional Commits:

```text
feat: adiciona inventário de hardware
fix: corrige validação do número de chamado
docs: documenta arquitetura MVC
refactor: reorganiza serviços de diagnóstico
```

## Branches

```text
main
develop
feature/nome-da-feature
fix/nome-do-ajuste
docs/nome-da-documentacao
```

## Estilo

- Funções pequenas.
- Responsabilidade única.
- Mensagens claras em português.
- Tratamento de erro com try/catch.
- Evitar alteração automática sem confirmação.
