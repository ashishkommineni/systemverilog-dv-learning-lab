#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
build="$root/build/verilator"
verilator_bin=${VERILATOR:-verilator}
pass_count=0

rm -rf "$build"
mkdir -p "$build"

while read -r source top extra; do
  [[ -z "$source" ]] && continue
  out="$build/$top"
  extra_sources=()
  if [[ -n "$extra" ]]; then
    extra_sources+=("$root/$extra")
  fi
  echo "[RUN] $top"
  "$verilator_bin" --binary --timing --assert -Wall -Wno-fatal \
    --Mdir "$out" --top-module "$top" \
    "${extra_sources[@]}" "$root/$source"
  "$out/V$top" | tee "$build/$top.txt"
  grep -q "$top: PASS" "$build/$top.txt"
  pass_count=$((pass_count + 1))
done <<'CASES'
lessons/01_language_fundamentals/data_types_demo.sv data_types_demo
lessons/01_language_fundamentals/operators_casting_demo.sv operators_casting_demo
lessons/01_language_fundamentals/procedural_demo.sv procedural_demo
lessons/01_language_fundamentals/tasks_functions_demo.sv tasks_functions_demo
lessons/02_arrays_collections/arrays_demo.sv arrays_demo
lessons/03_oop/oop_demo.sv oop_demo
lessons/06_interfaces_packages/interface_demo.sv interface_demo
lessons/07_assertions_coverage/assertions_demo.sv assertions_demo
lessons/08_mini_verification_project/counter_portable_smoke.sv counter_portable_smoke lessons/08_mini_verification_project/counter_dut.sv
CASES

echo "Portable suite: $pass_count/9 PASS"
