#!/usr/bin/env bash
# Composition root: instancia contratos, services, adapters e views uma única vez.
ons_cleanup() {
 if [[ -n "${ONS_TEMP_DIR:-}" && -d "$ONS_TEMP_DIR" ]]; then rm -rf -- "$ONS_TEMP_DIR"; fi
}
source "$ROOT_DIR/src/linux/Domain/Result.sh"
source "$ROOT_DIR/src/linux/Services/CatalogService.sh"
source "$ROOT_DIR/src/linux/Adapters/EquipmentAdapter.sh"
source "$ROOT_DIR/src/linux/Adapters/ProbeAdapter.sh"
source "$ROOT_DIR/src/linux/Adapters/PrintAdapter.sh"
source "$ROOT_DIR/src/linux/Services/TroubleshootingService.sh"
source "$ROOT_DIR/src/linux/Services/ChecklistService.sh"
source "$ROOT_DIR/src/linux/Services/DiagnosticService.sh"
source "$ROOT_DIR/src/linux/Services/ReportService.sh"
source "$ROOT_DIR/src/linux/Views/EquipmentView.sh"
source "$ROOT_DIR/src/linux/Views/TerminalView.sh"
source "$ROOT_DIR/src/linux/Views/ChecklistView.sh"
source "$ROOT_DIR/src/linux/Controllers/SessionController.sh"
