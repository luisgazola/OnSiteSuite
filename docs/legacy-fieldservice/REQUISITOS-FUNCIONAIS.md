# Requisitos Funcionais — FieldServiceSuite

## RF01 — Cadastro do atendimento

O sistema deve solicitar e armazenar:

- Nome do técnico
- Cliente
- Unidade/local
- Cidade
- Número do chamado
- Patrimônio
- Número de série
- Defeito relatado
- Observação inicial

## RF02 — Validação com Regex

Campos principais devem ser validados:

```regex
Chamado: ^(INC|SR|HD|CH)?[- ]?\d{5,12}$
Nome: ^[A-Za-zÀ-ÿ' -]{3,80}$
Cliente: ^[A-Za-zÀ-ÿ0-9&().,' -]{3,120}$
Patrimônio: ^[A-Za-z0-9_-]{3,40}$
Serial: ^[A-Za-z0-9_-]{4,40}$
```

## RF03 — Diagnóstico rápido

Coletar dados essenciais:

- Sistema operacional
- Fabricante/modelo
- Serial
- BIOS
- CPU
- RAM
- Disco/SSD
- Bateria
- Rede
- Drivers com erro
- Eventos críticos do Windows

## RF04 — Análise de disco/SSD

Verificar:

- Saúde do disco
- Temperatura
- Espaço livre
- Horas ligado, quando disponível
- Ciclos de energia, quando disponível
- Erros SMART disponíveis

## RF05 — Análise de bateria

Coletar:

- Carga atual
- Capacidade projetada
- Capacidade máxima atual
- Desgaste estimado
- Autonomia estimada, quando disponível

## RF06 — Desempenho simples

Verificar:

- Uso de CPU
- Uso de memória
- Uso de disco
- Processos que mais consomem recursos

## RF07 — Diagnóstico de rede

Testar:

- IP local
- Gateway
- DNS
- Ping no gateway
- Ping externo
- Resolução DNS
- Adaptador ativo

## RF08 — Energia

Permitir ações com confirmação:

- Desativar suspensão
- Desativar hibernação
- Evitar desligamento da tela
- Configurar ação ao fechar tampa
- Restaurar padrão

## RF09 — Drivers

Listar:

- Dispositivos com erro
- Drivers ausentes
- Código do erro
- Nome do dispositivo
- Hardware ID, quando disponível

## RF10 — Checklist manual

Permitir registrar itens verificados pelo técnico:

- Liga/desliga
- Carregador
- Tela
- Teclado
- Touchpad/mouse
- Wi-Fi
- Áudio
- Webcam
- Limpeza básica

## RF11 — Base OK/Atenção/Crítico

Classificar resultados em:

- OK
- Atenção
- Crítico
- Não coletado

## RF12 — Recomendações automáticas

Gerar recomendações simples conforme os achados.

## RF13 — Dashboard

Exibir resumo visual do atendimento e dos principais alertas.

## RF14 — Relatórios

Gerar relatórios em:

- HTML
- TXT
- JSON

## RF15 — Organização dos relatórios

Salvar em:

```text
Reports\ANO\MES\DIA\CHAMADO-SERIAL\
```

## RF16 — Troubleshooting guiado

Sugerir fluxo de análise conforme o defeito relatado.

## RF17 — Motor simples de regras

Cruzar sintomas e evidências para indicar causa provável.

## RF18 — Base de ações recomendadas

Manter ações técnicas em arquivo JSON configurável.

## RF19 — Inventário de hardware

Coletar dados do equipamento para relatório e controle técnico.
