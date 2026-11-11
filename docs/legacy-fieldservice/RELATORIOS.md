# Relatórios — FieldServiceSuite

## Objetivo

Gerar evidência técnica do atendimento para registro, auditoria e comunicação com cliente ou equipe interna.

## Pasta padrão

```text
Reports\ANO\MES\DIA\CHAMADO-SERIAL\
```

## Formatos

### HTML

Indicado para leitura visual.

Deve conter:

- Cabeçalho do atendimento
- Dashboard resumido
- Inventário
- Diagnóstico
- Troubleshooting
- Recomendações
- Checklist
- Conclusão

### TXT

Indicado para colar em sistemas de chamados.

### JSON

Indicado para integração futura, histórico e automação.

## Nomenclatura sugerida

```text
Relatorio-CHAMADO-SERIAL.html
Relatorio-CHAMADO-SERIAL.txt
Relatorio-CHAMADO-SERIAL.json
```

## Conteúdo mínimo

- Técnico
- Cliente
- Chamado
- Defeito relatado
- Serial
- Modelo
- Data/hora
- Resultados coletados
- Status OK/Atenção/Crítico
- Recomendações
- Observação final
