#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/jobs"
cat > "$TMP/bin/lp" <<'MOCK'
#!/usr/bin/env bash
set -Eeuo pipefail
counter="$ONS_TEST_JOB_DIR/counter"
n=0; [[ -f "$counter" ]] && read -r n < "$counter"
n=$((n+1)); printf '%s\n' "$n" > "$counter"
cp -- "${@: -1}" "$ONS_TEST_JOB_DIR/job-$n.bin"
printf '%s\n' "$*" > "$ONS_TEST_JOB_DIR/args-$n.txt"
printf 'request id is FAKE-%s (mock)\n' "$n"
MOCK
chmod +x "$TMP/bin/lp"
export ONS_TEST_JOB_DIR="$TMP/jobs"
export PATH="$TMP/bin:$PATH"
# 1 / 3 / 5 impressões numeradas sem guilhotina, mais personalizada com guilhotina RAW.
for count in 1 3 5; do
 before=0; [[ -f "$TMP/jobs/counter" ]] && read -r before < "$TMP/jobs/counter"
 folder="$($ROOT/onsite.sh --print-test FILA_TESTE --print-count "$count" --print-brand Epson --print-model TM-T20 --yes-print --output "$TMP/reports" --quiet)"
 jq -e '.version=="2.2.0" and (.tests | any(.id=="print_batch"))' "$folder/relatorio.json" > /dev/null
 jq -e --arg n "$count" '[.tests[] | select(.id=="print_batch") | .summary]|join(" ")|contains($n)' "$folder/relatorio.json" > /dev/null
 [[ -f "$folder/comprovante-impressao.txt" ]]
 grep -q "Impressão Número: $count" "$folder/comprovante-impressao.txt"
 read -r after < "$TMP/jobs/counter"
 ((after - before == count))
done
before=0; read -r before < "$TMP/jobs/counter"
folder="$($ROOT/onsite.sh --print-test FILA_TESTE --print-count 7 --escpos-raw --cut-after-each --yes-print --yes-cut --output "$TMP/reports" --quiet)"
read -r after < "$TMP/jobs/counter"
((after - before == 1))
[[ -f "$TMP/jobs/job-$after.bin" ]]
cutCount="$(od -An -tx1 -v "$TMP/jobs/job-$after.bin" | tr '\n' ' ' | grep -o '1d 56 00' | wc -l)"
[[ "$cutCount" -eq 7 ]]
grep -q 'Impressão Número: 7' "$folder/comprovante-impressao.txt"
grep -q -- '-o raw' "$TMP/jobs/args-$after.txt"
jq -e '.tests|any(.id=="print_batch" and .status=="INCONCLUSIVO")' "$folder/relatorio.json" >/dev/null
if "$ROOT/onsite.sh" --print-test FILA_TESTE --print-count 101 --yes-print --output "$TMP" >/dev/null 2>&1; then echo 'count exceeded accepted' >&2; exit 1; fi
if "$ROOT/onsite.sh" --print-test FILA_TESTE --print-count 5 --escpos-raw --cut-after-each --yes-print --output "$TMP" >/dev/null 2>&1; then echo 'cut without yes-cut accepted' >&2; exit 1; fi
if "$ROOT/onsite.sh" --print-test FILA_TESTE --print-count 5 --cut-after-each --yes-cut --yes-print --output "$TMP" >/dev/null 2>&1; then echo 'non-ESC/POS cut accepted' >&2; exit 1; fi
printf 'OK: impressão 1/3/5/7 simulada, sequência RAW e 7 comandos de guilhotina.\n'
