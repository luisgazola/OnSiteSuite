# Guia de Uso — FieldServiceSuite

## Objetivo

O FieldServiceSuite é uma ferramenta em PowerShell para uso diário de técnico Field Service. Ele ajuda a registrar o atendimento, coletar inventário de hardware, executar diagnóstico rápido, orientar troubleshooting, exibir dashboard e gerar relatório técnico.

## Como executar

Abra o PowerShell na pasta do projeto e execute:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Start.ps1
```

## Fluxo recomendado em campo

1. Iniciar novo atendimento.
2. Preencher técnico, cliente, chamado, serial e defeito relatado.
3. Executar inventário de hardware.
4. Executar diagnóstico rápido.
5. Abrir troubleshooting guiado conforme o defeito.
6. Preencher checklist manual.
7. Conferir dashboard.
8. Gerar relatório HTML, TXT e JSON.

## Menu

```text
1. Novo atendimento
2. Diagnóstico rápido
3. Troubleshooting guiado
4. Inventário de hardware
5. Rede
6. Disco/SMART
7. Bateria
8. Energia
9. Drivers
10. Checklist manual
11. Dashboard
12. Gerar relatório
0. Sair
```

## Saída dos relatórios

Os relatórios seguem o padrão:

```text
Reports\ANO\MES\DIA\NUMERO-DO-CHAMADO-NUMERO-DE-SERIE\
```

Exemplo:

```text
Reports\2026\07\09\INC123456-NXK123ABC\
```

## Formatos gerados

- HTML: leitura profissional e visual.
- TXT: registro simples e compatível com qualquer sistema.
- JSON: integração futura e análise automatizada.

## Observações importantes

- Algumas coletas podem exigir permissão administrativa.
- O sistema deve priorizar diagnóstico e relatório; alterações de energia devem pedir confirmação.
- Se um módulo falhar, o atendimento deve continuar e a falha deve ser registrada em log.
