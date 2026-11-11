# OnSiteSuite v2.0.1 — publicação no GitHub

Repositório existente: https://github.com/luisgazola/OnSiteSuite (branch `main`).
O histórico e a tag `v2.0.0` devem ser preservados.

## Publicação automatizada (Gentoo, Debian, Fedora ou Arch Linux)

Pré-requisitos: Git configurado, autenticação com permissão de push no GitHub,
`bash`, `jq` e `rsync`. Na pasta extraída `OnSiteSuite-v2.0.1`:

```bash
bash tests/check-catalog.sh
bash tests/equipment-linux.sh
bash tests/smoke-linux.sh
bash scripts/publish-github.sh
```

O script clona a branch main do repositório existente numa pasta nova,
sobrepõe os arquivos da versão 2.0.1 **sem apagar arquivos remotos não incluídos**,
cria um commit e uma tag anotada `v2.0.1`, e publica ambos.
Se a tag já existir, o script recusa a operação, sem movê-la.
Não executa renomeação de repositório, force-push ou reset de branch.

## Publicação manual

```bash
git clone https://github.com/luisgazola/OnSiteSuite.git
cd OnSiteSuite
# Copie para cá os arquivos da pasta OnSiteSuite-v2.0.1, exceto Reports/ e .git/
git add -A
git diff --cached --check
git commit -m "feat: equipamento na abertura do OnSiteSuite v2.0.1"
git tag -a v2.0.1 -m "OnSiteSuite v2.0.1"
git push origin main
git push origin v2.0.1
```

## Conferência pós-publicação

```bash
git log -2 --oneline
git tag --list 'v2.0.*'
git remote -v
```

O adaptador Windows é candidato a homologação; não declarar suporte operacional plenamente validado sem teste real.
