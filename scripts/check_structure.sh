#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)

required=(
  README.md
  LICENSE
  Makefile
  docs/learning_path.md
  docs/simulator_notes.md
  docs/topic_index.md
  docs/verification_report.md
  lessons/01_language_fundamentals/README.md
  lessons/02_arrays_collections/README.md
  lessons/03_oop/README.md
  lessons/04_randomization_constraints/README.md
  lessons/05_concurrency_ipc/README.md
  lessons/06_interfaces_packages/README.md
  lessons/07_assertions_coverage/README.md
  lessons/08_mini_verification_project/README.md
  lessons/09_interview_practice/README.md
)

for item in "${required[@]}"; do
  if [[ ! -s "$root/$item" ]]; then
    echo "Missing or empty: $item" >&2
    exit 1
  fi
done

bad=$(find "$root" -type f \( -name '*.log' -o -name '*.vcd' -o -name '*.fst' -o -name '*.wlf' -o -name '*.bak' -o -name '*.key' \) -print)
if [[ -n "$bad" ]]; then
  echo "Generated artifacts are tracked:" >&2
  echo "$bad" >&2
  exit 1
fi

echo "Repository checks: PASS"
