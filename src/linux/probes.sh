#!/usr/bin/env bash
# Compatibilidade com importações da v2.0.1. Usar Bootstrap.sh nas integrações novas.
_ONS_PROBE_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$_ONS_PROBE_ROOT/Adapters/ProbeAdapter.sh"
source "$_ONS_PROBE_ROOT/Services/TroubleshootingService.sh"
