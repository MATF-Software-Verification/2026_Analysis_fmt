#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RESULT_DIR="$ROOT_DIR/cppcheck/results"
RESULT_FILE="$RESULT_DIR/cppcheck_report.txt"

mkdir -p "$RESULT_DIR"

cppcheck \
  --enable=warning,style,performance,portability \
  --inconclusive \
  --force \
  --std=c++20 \
  --language=c++ \
  --inline-suppr \
  --suppress=missingIncludeSystem \
  --template='{file}:{line}:{column}: {severity}: {message} [{id}]' \
  -I "$ROOT_DIR/fmt/include" \
  "$ROOT_DIR/fmt/include" \
  "$ROOT_DIR/fmt/src" \
  2> "$RESULT_FILE"

echo "Cppcheck analysis completed successfully."
echo "Result: $RESULT_FILE"