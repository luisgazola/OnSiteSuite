#!/usr/bin/env bash
# OnSiteSuite v2.1.0 — release sobre o repositório renomeado (sem perda do histórico).
set -Eeuo pipefail
SRC="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPO='https://github.com/luisgazola/OnSiteSuite.git'
VERSION="$(tr -d '\r\n' < "$SRC/VERSION")"
TAG="v$VERSION"
DEST="${PUBLISH_DIR:-$(dirname "$SRC")/OnSiteSuite-release-${VERSION}-terminals}"
for command_name in git jq rsync bash; do
  command -v "$command_name" >/dev/null || { echo "Dependência ausente: $command_name" >&2; exit 1; }
done
[[ "$VERSION" == '2.1.0' ]] || { echo 'Este script publica somente v2.1.0' >&2; exit 1; }
[[ ! -e "$DEST" ]] || { echo "Destino já existe: $DEST" >&2; exit 1; }
if ! git var GIT_AUTHOR_IDENT >/dev/null 2>&1 || ! git var GIT_COMMITTER_IDENT >/dev/null 2>&1; then
  echo 'Configure git user.name e user.email antes de publicar.' >&2; exit 1
fi
bash "$SRC/tests/run-linux.sh"
TAG_EXISTS=0
if git ls-remote --exit-code --tags "$REPO" "refs/tags/$TAG" >/dev/null 2>&1; then
  TAG_EXISTS=1
  echo "A tag $TAG já existe e permanecerá IMUTÁVEL; somente a branch main será atualizada."
fi
# Clone novo evita operações destrutivas na cópia de trabalho do usuário.
git clone --branch main "$REPO" "$DEST"
rsync -rlptD --delete \
  --exclude='/.git/' --exclude='/Reports/' --exclude='/Logs/' \
  --exclude='/build/' --exclude='/.env' --exclude='/.env.*' \
  --exclude='*.key' --exclude='*.pem' --exclude='*.p12' --exclude='*.pfx' \
  "$SRC/" "$DEST/"
cd "$DEST"
git add -A
git -c core.whitespace=-blank-at-eol diff --cached --check
if git diff --cached --quiet; then echo 'Nenhuma modificação em relação à main.' >&2; exit 1; fi
git diff --cached --stat
git commit -m "feat: support GNOME kgx and Windows CMD/PowerShell terminals v$VERSION"
if (( TAG_EXISTS == 0 )); then
  git tag -a "$TAG" -m "OnSiteSuite v$VERSION — USB monitor, printing and terminal compatibility"
fi
git push origin main
if (( TAG_EXISTS == 0 )); then
  git push origin "$TAG"
  printf '\nPublicado: https://github.com/luisgazola/OnSiteSuite (main e tag %s)\n' "$TAG"
else
  printf '\nAtualizado: https://github.com/luisgazola/OnSiteSuite (main). Tag %s preservada.\n' "$TAG"
fi
