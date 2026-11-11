# PROJECT_CHARTER.md

# FieldServiceSuite Enterprise

**Versão:** 1.0.0  
**Status:** Em desenvolvimento  
**Autor:** Luís Gazola  
**Licença:** MIT

---

## 1. Visão do Projeto

O FieldServiceSuite Enterprise é uma ferramenta desenvolvida em PowerShell destinada a técnicos de Field Service, Suporte Técnico e Infraestrutura.

Seu propósito é padronizar o processo de atendimento técnico presencial através da coleta automatizada de informações, execução de diagnósticos, orientação de troubleshooting e geração de relatórios profissionais.

O projeto busca unir simplicidade operacional, arquitetura de software moderna e boas práticas de engenharia de software.

---

## 2. Missão

Fornecer uma ferramenta rápida, confiável e intuitiva que auxilie técnicos durante o atendimento em campo, reduzindo o tempo de diagnóstico, aumentando a qualidade das análises e padronizando os relatórios técnicos.

---

## 3. Visão

Tornar-se uma ferramenta Open Source em PowerShell voltada para técnicos de Field Service e profissionais de infraestrutura Windows.

---

## 4. Público-alvo

- Técnicos de Field Service
- Técnicos de Suporte N1
- Técnicos de Suporte N2
- Analistas de Infraestrutura
- Empresas de outsourcing
- Profissionais autônomos
- Estudantes de infraestrutura

---

## 5. Objetivos

O projeto deverá:

- Padronizar atendimentos
- Reduzir tempo de diagnóstico
- Facilitar auditorias
- Gerar inventário automaticamente
- Produzir relatórios profissionais
- Auxiliar no troubleshooting
- Criar documentação técnica
- Servir como portfólio profissional

---

## 6. Escopo

O projeto contempla:

- Cadastro do atendimento
- Inventário do equipamento
- Diagnóstico rápido
- Troubleshooting guiado
- Dashboard
- Recomendações automáticas
- Checklist técnico
- Configurações de energia
- Diagnóstico de rede
- Diagnóstico de armazenamento
- Diagnóstico de bateria
- Diagnóstico de drivers
- Relatórios HTML, TXT e JSON
- Registro de logs

---

## 7. Fora do Escopo

O projeto não pretende substituir soluções como:

- GLPI
- OCS Inventory
- SCCM
- Intune
- ServiceNow
- PDQ Deploy
- Lansweeper
- AnyDesk
- TeamViewer
- Sistemas ITSM

Também não realizará:

- Monitoramento contínuo
- Inventário em rede
- Administração remota
- Gerenciamento de chamados
- Banco de dados corporativo obrigatório
- Alterações automáticas sem confirmação

---

## 8. Princípios

Todo desenvolvimento deverá seguir:

- Simplicidade
- Clareza
- Legibilidade
- Modularidade
- Baixo acoplamento
- Alta coesão
- Reutilização
- Facilidade de manutenção
- Portabilidade
- Robustez

---

## 9. Arquitetura

Arquitetura adotada:

```text
MVC + Service Layer

Presentation
    ↓
Controller
    ↓
Service
    ↓
Rules Engine
    ↓
Knowledge Base
    ↓
Model
    ↓
View
```

---

## 10. Estrutura do Projeto

```text
FieldServiceSuite
├── Start.ps1
├── src
│   ├── Core
│   ├── Controllers
│   ├── Models
│   ├── Views
│   ├── Services
│   ├── RulesEngine
│   ├── Helpers
│   └── Validators
├── Config
├── KnowledgeBase
├── Assets
├── Reports
├── Logs
├── Docs
└── Tests
```

---

## 11. Convenções

- Pastas: PascalCase
- Arquivos: PascalCase.ps1 ou PascalCase.psm1
- Funções: Verb-Noun
- Variáveis: camelCase
- Constantes: UPPER_CASE

Exemplos:

```powershell
Get-HardwareInventory
Get-NetworkInformation
Invoke-Diagnostics
New-TechnicalReport
```

---

## 12. Padrões de Código

Seguir:

- PowerShell Best Practices
- Microsoft Coding Guidelines
- SOLID
- DRY
- KISS
- YAGNI
- Clean Code

---

## 13. Tratamento de Erros

Todo módulo deverá possuir:

- Try/Catch/Finally quando necessário
- Logs detalhados
- Mensagens amigáveis
- Retorno padronizado

Nenhum erro isolado poderá interromper completamente o atendimento.

---

## 14. Base de Conhecimento

Toda regra técnica deverá ser separada do código sempre que possível.

Exemplo:

```text
KnowledgeBase
├── Battery.json
├── Network.json
├── Storage.json
├── Symptoms.json
├── Recommendations.json
└── TroubleshootingFlows.json
```

---

## 15. Configuração

Toda configuração deverá ser realizada via JSON.

Nenhum limite técnico deverá ficar fixo diretamente no código quando puder ser parametrizado.

---

## 16. Interface

A interface deverá ser:

- Limpa
- Objetiva
- Elegante
- Padronizada
- Responsiva para terminal

Utilizar:

- Cards
- Ícones Unicode discretos
- Cores moderadas
- Barra de progresso
- Dashboard

---

## 17. Dashboard

O dashboard deverá apresentar:

- Dados do atendimento
- Resumo do inventário
- Resumo do diagnóstico
- Status geral
- Alertas
- Recomendações
- Tempo do atendimento

---

## 18. Relatórios

Formatos obrigatórios:

- HTML
- TXT
- JSON

Estrutura:

```text
Reports\ANO\MES\DIA\CHAMADO-SERIAL\
```

---

## 19. Logs

Estrutura:

```text
Logs\ANO\MES\arquivo.log
```

---

## 20. Versionamento

Seguir SemVer:

```text
1.0.0
1.1.0
1.2.0
2.0.0
```

---

## 21. Commits

Utilizar Conventional Commits:

```text
feat:
fix:
refactor:
docs:
style:
test:
perf:
build:
ci:
chore:
```

---

## 22. Testes

Todo módulo deverá ser planejado para testes com Pester.

---

## 23. Documentação

Arquivos mínimos:

- README.md
- PROJECT_CHARTER.md
- Docs/ARCHITECTURE.md
- Docs/DIAGRAMS.md
- Docs/TROUBLESHOOTING.md
- Docs/DEVELOPER-GUIDE.md
- Docs/ROADMAP.md
- CHANGELOG.md

---

## 24. Critérios para Inclusão de Novas Funcionalidades

Uma nova funcionalidade somente será aceita se:

- Resolver um problema real de Field Service
- Reduzir tempo de atendimento
- Não aumentar significativamente a complexidade do sistema
- Manter a arquitetura existente
- Possuir documentação
- Ser testável
- Seguir os padrões do projeto

---

## 25. Roadmap Estratégico

### Versão 1.x

- Cadastro do atendimento
- Diagnóstico rápido
- Dashboard
- Inventário
- Relatórios
- Troubleshooting guiado

### Versão 2.x

- Base de conhecimento ampliada
- Dashboard mais rico
- Exportação PDF
- Histórico local opcional
- Comparação entre diagnósticos

### Versão 3.x

- Interface gráfica opcional
- Plugins
- Integrações opcionais
- API REST opcional
- Sincronização opcional

---

## 26. Filosofia do Projeto

O FieldServiceSuite Enterprise não busca ser o software com mais funcionalidades, mas sim uma ferramenta confiável, organizada e eficiente para o trabalho diário do técnico de Field Service.

Cada recurso adicionado deve responder a uma pergunta simples:

> Esta funcionalidade torna o atendimento mais rápido, mais preciso ou mais fácil para o técnico em campo?

Se a resposta for não, ela deve ser reavaliada antes de ser incorporada ao projeto.
