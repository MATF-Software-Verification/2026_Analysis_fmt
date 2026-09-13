#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FMT_DIR="$ROOT_DIR/fmt"
RESULT_DIR="$ROOT_DIR/clang_format/results"
RESULT_FILE="$RESULT_DIR/clang_format_report.txt"

TARGET_FILES=(
  "include/fmt/base.h"
  "include/fmt/format.h"
  "src/os.cc"
)

mkdir -p "$RESULT_DIR"

{
  echo "clang-format version:"
  clang-format --version
  echo
  echo "Configuration: $FMT_DIR/.clang-format"
  echo "Checked files:"
  printf '%s\n' "${TARGET_FILES[@]}"
  echo
} > "$RESULT_FILE"

cd "$FMT_DIR"

if clang-format \
  --dry-run \
  --Werror \
  --style=file \
  "${TARGET_FILES[@]}" \
  2>> "$RESULT_FILE"; then
  echo "Result: all selected files comply with the project formatting rules." \
    >> "$RESULT_FILE"
else
  status=$?
  echo "Result: formatting differences were detected." >> "$RESULT_FILE"
  exit "$status"
fi

echo "clang-format analysis completed successfully."
echo "Result: $RESULT_FILE"