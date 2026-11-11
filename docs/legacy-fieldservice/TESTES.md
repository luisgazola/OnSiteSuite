# Testes — FieldServiceSuite

## Testes manuais iniciais

### Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Start.ps1
```

Validar:

- Menu abre corretamente.
- Novo atendimento aceita dados válidos.
- Regex bloqueia dados inválidos.
- Diagnóstico rápido não interrompe em caso de falha parcial.
- Dashboard exibe resumo.
- Relatório HTML/TXT/JSON é gerado.

## Testes por módulo

### Atendimento

- Nome válido.
- Nome inválido.
- Chamado válido.
- Chamado inválido.
- Serial válido.
- Serial inválido.

### Diagnóstico

- Execução com usuário comum.
- Execução como administrador.
- Máquina com bateria.
- Máquina sem bateria.
- Máquina com um disco.
- Máquina com mais de um disco.

### Rede

- Com internet.
- Sem internet.
- DNS falhando.
- Gateway inacessível.

### Relatórios

- Pasta criada corretamente.
- HTML abre no navegador.
- TXT legível.
- JSON válido.

## Futuro

Adicionar Pester para validação automatizada de:

- Regex
- JSON
- Regras
- Geração de caminhos
- Exportação de relatório
