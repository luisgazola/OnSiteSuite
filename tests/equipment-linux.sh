#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# Funções de coleta aceitam ausência de dados, sem precisar de root ou hardware real.
source "$ROOT/src/linux/Adapters/EquipmentAdapter.sh"
source "$ROOT/src/linux/Views/EquipmentView.sh"
[[ "$(ons_chassis_type 13)" == 'AIO (All-in-One)' ]]
[[ "$(ons_chassis_type 9)" == 'Notebook' ]]
[[ "$(ons_chassis_type 3)" == 'Desktop' ]]
[[ "$(ons_chassis_type 23)" == 'Não identificado' ]]
[[ "$(ons_clean 'To Be Filled By O.E.M.')" == 'Não identificado' ]]
[[ "$(ons_clean $'Test\e[31mSerial')" == 'Test[31mSerial' ]]
# Coleta simulada de Dell com serial; teste sem dependência de DMI real.
ons_dmi() {
 case "$1" in
  sys_vendor) printf 'Dell Inc.' ;;
  product_name) printf 'Latitude 5550' ;;
  product_serial) printf 'ABC1234' ;;
  chassis_type) printf '9' ;;
 esac
}
ons_linux_os() { printf 'Fedora Linux'; }
ons_linux_cpu() { printf 'Intel Core i5'; }
ons_linux_memory() { printf '16.0 GiB'; }
ons_linux_storage() { printf 'nvme0n1 512G'; }
fixture="$(ons_collect_equipment)"
jq -e '.serviceTag=="ABC1234" and .numeroSerie=="ABC1234" and .marca=="Dell Inc." and .tipo=="Notebook" and .sistemaOperacional=="Fedora Linux"' <<<"$fixture" >/dev/null
panel="$(ons_show_equipment "$fixture" 2.0.3)"
grep -q 'Latitude 5550' <<<"$panel"
# Equipamento não Dell não deve receber Service Tag inventada.
ons_dmi() { case "$1" in sys_vendor) printf 'Lenovo' ;; product_serial) printf 'SER543' ;; esac; }
fixture="$(ons_collect_equipment)"
jq -e '.serviceTag=="Não identificado" and .numeroSerie=="SER543"' <<<"$fixture" >/dev/null
printf 'OK: equipamento, tratamento de dados ausentes e formatos.\n'
