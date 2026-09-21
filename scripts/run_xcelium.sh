#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
build="$root/build/xcelium"
xrun_bin=${XRUN:-xrun}

if ! command -v "$xrun_bin" >/dev/null 2>&1; then
  echo "Cadence Xcelium was not found. Set XRUN or add xrun to PATH." >&2
  exit 2
fi

rm -rf "$build"
mkdir -p "$build"
cd "$build"

run_one() {
  name=$1
  shift
  echo "[XRUN] $name"
  "$xrun_bin" -64bit -sv -access +rwc -clean "$@" -l "$name.log"
  grep -q "$name: PASS" "$name.log"
}

run_one four_state_demo "$root/lessons/01_language_fundamentals/four_state_demo.sv"
run_one constraints_demo "$root/lessons/04_randomization_constraints/constraints_demo.sv"
run_one processes_demo "$root/lessons/05_concurrency_ipc/processes_demo.sv"
run_one ipc_demo "$root/lessons/05_concurrency_ipc/ipc_demo.sv"
run_one virtual_interface_demo "$root/lessons/06_interfaces_packages/virtual_interface_demo.sv"
run_one coverage_demo -coverage all -covoverwrite "$root/lessons/07_assertions_coverage/coverage_demo.sv"
run_one bind_demo "$root/lessons/07_assertions_coverage/bind_demo.sv"

echo "[XRUN] tb_top"
"$xrun_bin" -64bit -sv -access +rwc -clean -coverage all -covoverwrite \
  "$root/lessons/08_mini_verification_project/counter_if.sv" \
  "$root/lessons/08_mini_verification_project/counter_dut.sv" \
  "$root/lessons/08_mini_verification_project/counter_tb_pkg.sv" \
  "$root/lessons/08_mini_verification_project/tb_top.sv" \
  -top tb_top -l tb_top.log
grep -q "tb_top: PASS" tb_top.log

echo "Xcelium feature suite: 8/8 PASS"
