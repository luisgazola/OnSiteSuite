# Release 2.0.2 — Refatoração sem regressão funcional

**Release local preparado** para publicação. A tag `v2.0.2` não é criada automaticamente no GitHub pela geração deste pacote.

## Critérios de aceitação

- [x] `VERSION` é `2.0.2` e a CLI informa o mesmo valor.
- [x] Abertura e inventário do equipamento preservados no terminal.
- [x] Testes e parâmetros Linux preservados, sem OS obrigatória.
- [x] Catálogo e `schemaVersion: 2.0` mantidos.
- [x] Views, Controllers, Services, Domain e Adapters separados em Linux/Windows.
- [x] Funções PowerShell originais preservadas como adapters legados.
- [x] `runner.sh` e `Runner.ps1` reduzidos a entradas leves.
- [x] Testes de catálogo, equipamento, smoke, services mockados e schema no Linux.
- [ ] Testes PowerShell executados em Windows real; testar também CIM e dispositivos físicos.
- [ ] Publicação da tag `v2.0.2` no repositório oficial.

## Uso Linux

```bash
cd OnSiteSuite-v2.0.2
./onsite.sh --info
./onsite.sh --list-tests
./onsite.sh --tests system,cpu,memory,storage --output ./Reports
```

## Uso Windows (homologação pendente)

```powershell
Set-Location OnSiteSuite-v2.0.2
.\OnSiteSuite.ps1 -InfoOnly
.\OnSiteSuite.ps1 -Tests 'system,cpu,memory,storage' -NonInteractive
pwsh -NoProfile -File ./tests/architecture-windows.ps1
```

## Publicação Git sem sobrescrever versões anteriores

Para publicar sobre `main` no repositório `luisgazola/OnSiteSuite`, sem criar um repositório do zero:

```bash
bash scripts/publish-github.sh
```

Pré-requisitos: `git`, `rsync`, `jq`, `bash`, identidade Git configurada e autenticação para push.
O script clona `main` em uma **nova pasta**, testa Linux, aplica a nova árvore e publica commit e **nova tag anotada `v2.0.2`**, recusando sobrescrever tags existentes. Não mova `v2.0.0` ou `v2.0.1`.

## Limitações

A CLI Windows precisa de homologação real antes de ser promovida a produção. O contrato JSON é compartilhado; os renderizadores HTML ainda são próprios de cada SO. Veja `docs/ARCHITECTURE.md`.
