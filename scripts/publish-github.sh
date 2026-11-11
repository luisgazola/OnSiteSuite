#!/usr/bin/env bash
# OnSiteSuite v2.0.0 | Migração do repositório FieldServiceToolkit, preservando histórico Git.
set -Eeuo pipefail

OLD_REPO="luisgazola/FieldServiceToolkit"
NEW_REPO="luisgazola/OnSiteSuite"
NEW_URL="https://github.com/${NEW_REPO}.git"
VERSION="v2.0.0"
SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
DEST="${PUBLISH_DIR:-$(dirname "$SRC")/OnSiteSuite-git}"
SKIP_RENAME=0

usage() {
  cat <<'HELP'
Uso: bash scripts/publish-github.sh [--already-renamed]

  --already-renamed  Use quando você já renomeou o repositório
                     em GitHub > Settings > General.

Antes de executar: autentique o GitHub CLI com "gh auth login"
ou renomeie o repositório pelo navegador e use --already-renamed.
O script preserva os commits anteriores e publica a tag v2.0.0.
HELP
}
for arg in "$@"; do
  case "$arg" in
    --already-renamed) SKIP_RENAME=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção não reconhecida: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

# Valide a identidade de commit antes de qualquer alteração remota.
if ! git var GIT_AUTHOR_IDENT >/dev/null 2>&1 || ! git var GIT_COMMITTER_IDENT >/dev/null 2>&1; then
  echo "Identidade Git ausente. Configure user.name e user.email antes de prosseguir." >&2
  echo 'Ex.: git config --global user.name "Seu Nome"' >&2
  echo '     git config --global user.email "seu-email@exemplo.com"' >&2
  exit 1
fi

for cmd in git rsync jq bash; do
  command -v "$cmd" >/dev/null || { echo "Dependência ausente: $cmd" >&2; exit 1; }
done
[[ -f "$SRC/VERSION" && "$(cat "$SRC/VERSION")" == "2.0.0" ]] || {
  echo "Versão de origem inesperada. Abortando." >&2; exit 1;
}
[[ -f "$SRC/onsite.sh" && -f "$SRC/OnSiteSuite.ps1" ]] || {
  echo "Pasta de origem incompleta. Abortando." >&2; exit 1;
}
if [[ -e "$DEST" ]]; then
  echo "Destino já existe: $DEST" >&2
  echo "Defina PUBLISH_DIR para um diretório novo e vazio ou faça git pull manualmente." >&2
  exit 1
fi

# Não renomeia/publica código que não passou na suíte de verificações locais disponível.
bash "$SRC/tests/check-catalog.sh"
bash "$SRC/tests/smoke-linux.sh"

if (( SKIP_RENAME == 0 )); then
  command -v gh >/dev/null || {
    echo "GitHub CLI (gh) não encontrado." >&2
    echo "Renomeie em https://github.com/${OLD_REPO}/settings" >&2
    echo "Depois execute este script com --already-renamed." >&2
    exit 1
  }
  gh auth status >/dev/null || {
    echo "GitHub CLI não autenticado. Execute: gh auth login" >&2; exit 1;
  }

  if gh repo view "$NEW_REPO" --json nameWithOwner >/dev/null 2>&1; then
    echo "Repositório já se chama $NEW_REPO."
  elif gh repo view "$OLD_REPO" --json nameWithOwner >/dev/null 2>&1; then
    echo "Renomeando $OLD_REPO para $NEW_REPO..."
    gh repo rename OnSiteSuite --repo "$OLD_REPO" --yes
  else
    echo "Não foi possível localizar o repositório original ou renomeado." >&2
    exit 1
  fi
fi

echo "Clonando o repositório renomeado e seu histórico..."
git clone --branch main "$NEW_URL" "$DEST"
[[ -d "$DEST/.git" ]] || { echo "Falha no clone." >&2; exit 1; }

# O destino é um clone novo. --delete remove arquivos legados da árvore de trabalho,
# preservando todos os commits antigos no histórico Git.
rsync -a --delete \
  --exclude='/.git/' \
  --exclude='/Reports/' \
  --exclude='/Logs/' \
  --exclude='/build/' \
  --exclude='/.env' \
  --exclude='/.env.*' \
  --exclude='*.pem' \
  --exclude='*.key' \
  --exclude='*.p12' \
  --exclude='*.pfx' \
  "$SRC/" "$DEST/"

mkdir -p "$DEST/Reports"
touch "$DEST/Reports/.gitkeep"
cd "$DEST"

git remote set-url origin "$NEW_URL"
git add -A
# Documentação histórica pode conter dois espaços Markdown para quebra de linha.
git -c core.whitespace=-blank-at-eol diff --cached --check

if git diff --cached --quiet; then
  echo "Nenhum arquivo alterado na árvore de trabalho."
else
  echo "Resumo das alterações:"
  git diff --cached --stat
  git commit -m "feat: migrate FieldServiceToolkit to OnSiteSuite v2.0.0"
fi

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
  echo "A tag $VERSION já existe localmente; não será recriada."
else
  git tag -a "$VERSION" -m "OnSiteSuite v2.0.0 — suíte de diagnóstico consolidada"
fi

git push origin main
git push origin "$VERSION"

echo
echo "Publicado: https://github.com/$NEW_REPO"
echo "Branch: main | Tag: $VERSION"
echo "Clone local: $DEST"
echo "Verificação: git -C \"$DEST\" log -1 --oneline"
