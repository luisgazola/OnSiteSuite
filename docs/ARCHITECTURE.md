# OnSiteSuite 2.0.1 — arquitetura consolidada

O repositório unifica o **FieldServiceSuite/FieldServiceToolkit 1.2.0** do ZIP enviado e o escopo do **OnSiteSuite**.
Há **um produto**, um catálogo de testes, um padrão de laudo e dois adaptadores de sistemas operacionais.

```text
                 Config/tests.json
                         |
    +--------------------+--------------------+
    |                                         |
 onsite.sh (Linux/Bash)              OnSiteSuite.ps1 (Windows/Pwsh)
    |                                         |
 src/linux/probes.sh                 src/windows/Runner.ps1
    |                                         |
 /proc, /sys, lsblk, CUPS,            src/Services/*.psm1 (MVC/Services
 journalctl, smartctl opcional        migrados do FieldServiceToolkit)
    |                                         |
    +-------------> relatório v2 <------------+
                          |
                 JSON / TXT / HTML
                          |
           Integração futura opcional por API
```

## Núcleo preservado

O catálogo `Config/TroubleshootingFlows.json` é a fonte dos fluxos guiados. O arquivo homônimo em `KnowledgeBase` foi preservado por compatibilidade histórica. O código PowerShell do projeto de origem foi mantido nas pastas `src/Controllers`, `src/Services`, `src/Models`, `src/Views`, `src/Helpers`, `src/Validators`, `src/Core` e `src/RulesEngine` como patrimônio técnico reutilizável. O novo `OnSiteSuite.ps1` chama serviços existentes; não executa o menu antigo como segundo programa.

## Regras de engenharia

- Diagnóstico **sem OS por padrão**; dados de atendimento são metadados opcionais.
- Catálogo e IDs fixos em `config/tests.json` e relatório em `config/report.schema.json`.
- Resultados com `OK`, `ATENCAO`, `FALHA`, `INCONCLUSIVO` ou `NAO_SUPORTADO`.
- Nenhum teste pode declarar "hardware saudável" por ausência de evidência.
- Modificações em configuração, energia, disco, impressora ou rede são separadas das sondagens passivas.
- Relatórios não são enviados para nuvem. O usuário gerencia armazenamento e descarte.
- Os scripts são portáteis, sem Docker ou serviço de banco de dados.
- C++20 em `native/` é um componente auxiliar opcional. Qt GUI **não foi implementada** nesta entrega.
- O diagnóstico de impressão não envia página por padrão; o teste CUPS exige `--print-test ... --yes-print`.

## Precisão das conclusões

- Dados de CIM, `/sys` e SMART têm limitações e permissões próprias.
- `OK` significa que a coleta ou verificação específica foi concluída sem alerta detectado, **não** ausência de falhas.
- Testes de áudio/tela são de enumeração, não equivalem a percepção visual/auditiva.
- Nenhum comando faz reparos automáticos, corte de guilhotina, alteração de energia ou limpeza de disco.

## Identificação inicial (v2.0.1)

- Abertura interativa: coleta local, painel de contexto e menu de testes (nesta ordem).
- Caminho não interativo: painel omitido, para manter saída previsível; inventário fica nos laudos.
- Linux: `src/linux/equipment.sh`; Windows: `src/windows/Equipment.ps1`.
- Sem inferir números de série a partir de UUID, MAC ou serial de placa-mãe.
- Service Tag Dell é apresentada somente quando o fabricante é identificado e há serial confiável.
- `equipamento` é campo opcional no esquema JSON 2.0 para preservar compatibilidade.
- A interface não envia dados para servidores; logs/laudos permanecem locais.
