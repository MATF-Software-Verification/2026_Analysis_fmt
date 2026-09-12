#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FUZZ_DIR="$ROOT_DIR/fuzzing"
BUILD_DIR="$FUZZ_DIR/build"
OUTPUT_BIN="$BUILD_DIR/format_fuzzer"
ARTIFACT_DIR="$FUZZ_DIR/artifacts"
RUNS="${1:-2000}"

mkdir -p "$BUILD_DIR"
mkdir -p "$ARTIFACT_DIR"

clang++ \
  -std=c++20 \
  -O1 \
  -g \
  -fsanitize=fuzzer,address,undefined \
  -I "$ROOT_DIR/fmt/include" \
  "$FUZZ_DIR/format_fuzzer.cpp" \
  "$ROOT_DIR/fmt/src/format.cc" \
  -o "$OUTPUT_BIN"

ASAN_OPTIONS=detect_leaks=0 \
  "$OUTPUT_BIN" \
  "$FUZZ_DIR/corpus" \
  -artifact_prefix="$ARTIFACT_DIR/" \
  -runs="$RUNS"

echo
echo "Fuzzing completed."
echo "Binary: $OUTPUT_BIN"
echo "Artifacts directory: $ARTIFACT_DIR"
