# Contribuindo com o OnSiteSuite

O OnSiteSuite é um projeto de automação, diagnóstico e documentação para Field Service mantido pela Excelsior Soluções em Tecnologia. Contribuições de técnicos, entusiastas e desenvolvedores são bem-vindas.

## Antes de implementar

- Abra uma issue descrevendo comportamento esperado, plataforma, impactos e como reproduzir sem dados pessoais.
- Preserve o contrato `config/report.schema.json`, os IDs `config/tests.json` e a semântica dos estados de diagnóstico.
- Evite elevar privilégios, reparar equipamentos, conectar à internet, imprimir ou alterar estado físico sem consentimento explícito.
- Use versões específicas, sem `latest`; introduza dependências somente quando houver benefício mensurável.

## Organização de código

- `Controllers`: fluxo de sessão, opções e chamadas a services.
- `Views`: menu, terminal e checklist; sem acesso direto a hardware/arquivos de laudo.
- `Services`: orquestração dos diagnósticos e relatórios; sem tela interativa.
- `Domain`: contratos, modelos e estados.
- `Adapters`: coleta do sistema operacional e integração com código legado.

Mantenha Windows e Linux em paridade de contrato. Reutilize a base legada PowerShell por adapters em vez de duplicar código.

## Testar

Linux:

```bash
bash tests/check-catalog.sh
bash tests/equipment-linux.sh
bash tests/smoke-linux.sh
bash tests/architecture-linux.sh
bash tests/contract-linux.sh
```

Windows com PowerShell 7:

```powershell
pwsh -NoProfile -File ./tests/architecture-windows.ps1
```

Testes de impressoras, USB, SMART e bateria exigem registro de hardware e consentimento, nunca automatize ações físicas nos pipelines CI.

## Pull requests

Crie uma branch (por exemplo, `refactor/windows-report-service`), documente alterações e evidências de teste, siga Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`) e não inclua `Reports/`, logs, arquivos `.env`, chaves nem dados de clientes. Consulte `SECURITY.md` para reporte responsável.
