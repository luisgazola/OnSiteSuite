#!/usr/bin/env bash
# OnSiteSuite v2.0.1 — release sobre o repositório renomeado (sem perda do histórico).
set -Eeuo pipefail
SRC="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPO='https://github.com/luisgazola/OnSiteSuite.git'
VERSION="$(tr -d '\r\n' < "$SRC/VERSION")"
TAG="v$VERSION"
DEST="${PUBLISH_DIR:-$(dirname "$SRC")/OnSiteSuite-release-$VERSION}"
for command_name in git jq rsync bash; do
  command -v "$command_name" >/dev/null || { echo "Dependência ausente: $command_name" >&2; exit 1; }
done
[[ "$VERSION" == '2.0.1' ]] || { echo 'Este script publica somente v2.0.1' >&2; exit 1; }
[[ ! -e "$DEST" ]] || { echo "Destino já existe: $DEST" >&2; exit 1; }
if ! git var GIT_AUTHOR_IDENT >/dev/null 2>&1 || ! git var GIT_COMMITTER_IDENT >/dev/null 2>&1; then
  echo 'Configure git user.name e user.email antes de publicar.' >&2; exit 1
fi
bash "$SRC/tests/check-catalog.sh"
bash "$SRC/tests/equipment-linux.sh"
bash "$SRC/tests/smoke-linux.sh"
if git ls-remote --exit-code --tags "$REPO" "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG já existe no GitHub; nada será sobrescrito." >&2; exit 1
fi
# Clone novo evita operações destrutivas na cópia de trabalho do usuário.
git clone --branch main "$REPO" "$DEST"
rsync -rlptD \
  --exclude='/.git/' --exclude='/Reports/' --exclude='/Logs/' \
  --exclude='/build/' --exclude='/.env' --exclude='/.env.*' \
  --exclude='*.key' --exclude='*.pem' --exclude='*.p12' --exclude='*.pfx' \
  "$SRC/" "$DEST/"
cd "$DEST"
git add -A
git -c core.whitespace=-blank-at-eol diff --cached --check
if git diff --cached --quiet; then echo 'Nenhuma modificação em relação à main.' >&2; exit 1; fi
git diff --cached --stat
git commit -m "feat: equipment overview on OnSiteSuite v$VERSION"
git tag -a "$TAG" -m "OnSiteSuite v$VERSION — identificação inicial do equipamento"
git push origin main
git push origin "$TAG"
printf '\nPublicado: https://github.com/luisgazola/OnSiteSuite (main, %s)\n' "$TAG"
