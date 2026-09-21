#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
parser=${VERIBLE_SYNTAX:-verible-verilog-syntax}
count=0

while IFS= read -r source; do
  echo "[PARSE] $source"
  "$parser" "$source" >/dev/null
  count=$((count + 1))
done < <(find "$root/lessons" -name '*.sv' -type f | sort)

echo "SystemVerilog syntax: $count/$count PASS"
