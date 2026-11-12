#!/usr/bin/env bash
# Compatibilidade externa v2.0.1: funções de coleta + apresentação.
_ONS_EQUIPMENT_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$_ONS_EQUIPMENT_ROOT/Adapters/EquipmentAdapter.sh"
source "$_ONS_EQUIPMENT_ROOT/Views/EquipmentView.sh"
