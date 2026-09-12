#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PERF_DIR="$ROOT_DIR/perf"
BUILD_DIR="$PERF_DIR/build"
RESULT_DIR="$PERF_DIR/results"
WORKLOAD_SOURCE="$PERF_DIR/format_workload.cpp"
WORKLOAD_BINARY="$BUILD_DIR/format_workload"
RESULT_FILE="$RESULT_DIR/perf_stat.txt"

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

"$PERF_BIN" stat \
  --output "$RESULT_FILE" \
  "$WORKLOAD_BINARY"

echo "Performance analysis completed successfully."
echo "Result: $RESULT_FILE"