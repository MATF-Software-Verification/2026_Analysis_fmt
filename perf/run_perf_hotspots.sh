#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PERF_DIR="$ROOT_DIR/perf"
BUILD_DIR="$PERF_DIR/build"
RESULT_DIR="$PERF_DIR/results"
WORKLOAD_SOURCE="$PERF_DIR/format_workload.cpp"
WORKLOAD_BINARY="$BUILD_DIR/format_workload"
PERF_DATA="$RESULT_DIR/perf.data"
PERF_REPORT="$RESULT_DIR/perf_report.txt"

PERF_BIN="${PERF_BIN:-/usr/lib/linux-tools/6.8.0-139-generic/perf}"

if [[ ! -x "$PERF_BIN" ]]; then
  echo "perf binary not found: $PERF_BIN" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR" "$RESULT_DIR"

c++ \
  -std=c++20 \
  -O2 \
  -g \
  -DNDEBUG \
  -I "$ROOT_DIR/fmt/include" \
  "$WORKLOAD_SOURCE" \
  "$ROOT_DIR/fmt/src/format.cc" \
  -o "$WORKLOAD_BINARY"

"$PERF_BIN" record \
  --call-graph dwarf \
  -o "$PERF_DATA" \
  "$WORKLOAD_BINARY"

"$PERF_BIN" report \
  --stdio \
  --sort symbol \
  -i "$PERF_DATA" \
  > "$PERF_REPORT"

echo "Hot spot analysis completed successfully."
echo "Report: $PERF_REPORT"