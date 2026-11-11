# Migração do FieldServiceToolkit para OnSiteSuite

## Objetivo

Renomear **luisgazola/FieldServiceToolkit** para **luisgazola/OnSiteSuite** e publicar a versão `v2.0.0`
sobre a branch `main` existente, mantendo o histórico de commits do FieldServiceToolkit.

**Não crie outro repositório e não execute `git init` sobre o clone antigo.**

## Opção 1 — Um comando com GitHub CLI

Requisitos locais: `git`, `rsync`, `jq`, `bash`, `gh` autenticado (`gh auth login`).

Na pasta OnSiteSuite-v2.0.0:

```bash
bash scripts/publish-github.sh
```

O script valida o pacote, renomeia o repositório se ainda necessário, clona o histórico em uma pasta nova
(`OnSiteSuite-git` ao lado do pacote), sincroniza a nova árvore, registra um commit sobre os anteriores,
cria a tag anotada `v2.0.0` e envia branch e tag.

## Opção 2 — Renomear no navegador

1. Acesse: https://github.com/luisgazola/FieldServiceToolkit/settings
2. Em **General > Repository name**, altere para **OnSiteSuite** e clique **Rename**.
3. Na pasta OnSiteSuite-v2.0.0, execute:

```bash
bash scripts/publish-github.sh --already-renamed
```

O argumento `--already-renamed` não ignora autenticação de `git push`; é necessário já ter acesso Git configurado.

## Verificações após a publicação

```bash
git -C ../OnSiteSuite-git remote -v
git -C ../OnSiteSuite-git log -3 --oneline
git -C ../OnSiteSuite-git tag -l 'v2.0.0'
git -C ../OnSiteSuite-git status --short
```

URL final: https://github.com/luisgazola/OnSiteSuite

O GitHub redireciona a URL antiga em geral; mesmo assim, atualize os clones locais:

```bash
git remote set-url origin https://github.com/luisgazola/OnSiteSuite.git
```

**Atenção:** renomear o repositório não renomeia automaticamente diretórios locais.
Não reutilize `FieldServiceToolkit` como nome de outro repositório para não interromper os redirecionamentos.

## Histórico e arquivos

Os módulos PowerShell da versão 1.2.0 foram preservados em `src/`, assim como configurações e a base de conhecimento.
A documentação antiga foi reorganizada em `docs/legacy-fieldservice/`.
Os arquivos `Docs/` e outros legados podem desaparecer da **árvore atual**, mas seguem acessíveis nos **commits anteriores**.
Resultados de clientes em `Reports/`, logs, segredos e artefatos de build não devem ser publicados.
