# Troubleshooting Guiado — FieldServiceSuite

## Objetivo

Orientar o técnico a seguir uma linha de análise objetiva conforme o defeito relatado.

## Sintomas iniciais sugeridos

### Notebook lento

Fluxo:

1. Verificar uso de RAM.
2. Verificar uso de CPU.
3. Verificar disco/SMART.
4. Verificar espaço livre.
5. Verificar drivers com erro.
6. Verificar eventos críticos.

Possíveis conclusões:

- Gargalo de memória.
- Processo consumindo recursos.
- Armazenamento degradado.
- Windows com falhas de atualização.

### Sem internet

Fluxo:

1. Verificar adaptador ativo.
2. Verificar IP.
3. Testar gateway.
4. Testar DNS.
5. Testar ping externo.
6. Verificar driver de rede.

Possíveis conclusões:

- Falha de DNS.
- Gateway inacessível.
- Driver de rede com erro.
- Problema externo à máquina.

### Não carrega bateria

Fluxo:

1. Verificar presença da bateria.
2. Verificar carga atual.
3. Verificar desgaste.
4. Validar carregador.
5. Validar conector.
6. Validar eventos de energia.

Possíveis conclusões:

- Bateria degradada.
- Carregador defeituoso.
- Conector com mau contato.
- Falha de gerenciamento de energia.

### Tela azul / travamento

Fluxo:

1. Verificar eventos críticos.
2. Verificar WHEA.
3. Verificar disco/SMART.
4. Verificar drivers com erro.
5. Verificar temperatura.
6. Verificar atualizações recentes.

Possíveis conclusões:

- Driver instável.
- Falha de hardware.
- Disco degradado.
- Superaquecimento.

## Regras simples

Exemplos:

```text
RAM > 90% + defeito contém "lento" = Atenção: provável gargalo de memória.
SMART crítico = Crítico: recomendar backup e substituição.
Driver Código 28 = Atenção: driver ausente.
Gateway sem resposta = Atenção: validar rede local.
```

## Arquivos relacionados

- Config/TroubleshootingFlows.json
- Config/RecommendedActions.json
- App/Services/TroubleshootingService.psm1
- App/Services/RulesEngineService.psm1
- App/Services/RecommendationService.psm1
