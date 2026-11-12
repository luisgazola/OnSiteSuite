#!/usr/bin/env bash
# Verificação regressiva: arquitetura única, sem importadores legados.
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for old in   Config KnowledgeBase native Start.ps1   src/Core src/Controllers src/Helpers src/Models src/RulesEngine src/Services src/Validators src/Views   src/linux/probes.sh src/linux/equipment.sh src/windows/Equipment.ps1   src/windows/Adapters/LegacyPowerShellAdapter.ps1 docs/legacy-fieldservice; do
  if [[ -e "$ROOT/$old" ]]; then
    printf 'Código obsoleto ainda presente: %s\n' "$old" >&2
    exit 1
  fi
done
if grep -RInE 'Get-Fss[A-Za-z]+|Initialize-OnsLegacy|Import-FssLayer|\$global:FssState'   --include='*.sh' --include='*.ps1' "$ROOT/src"; then
  printf 'Há referências executáveis à implementação legada.\n' >&2
  exit 1
fi
[[ -s "$ROOT/config/troubleshooting-flows.json" ]]
jq -e 'type=="object" and (.notebook_lento|type=="array") and (.sem_internet|type=="array")'   "$ROOT/config/troubleshooting-flows.json" >/dev/null
[[ "$(cat "$ROOT/VERSION")" == '2.0.3' ]]
grep -Fq "WindowsDiagnosticAdapter.ps1" "$ROOT/src/windows/App/Bootstrap.ps1"
if grep -Fq 'Initialize-OnsLegacy' "$ROOT/src/windows/Controllers/SessionController.ps1"; then exit 1; fi
printf 'OK: arquitetura consolidada e caminhos obsoletos ausentes.\n'
