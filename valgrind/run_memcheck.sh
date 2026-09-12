#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/unit_tests/build"
TEST_BINARY="$BUILD_DIR/format_edge_tests"
RESULT_DIR="$ROOT_DIR/valgrind/results"
RESULT_FILE="$RESULT_DIR/memcheck.log"

mkdir -p "$RESULT_DIR"

cmake -S "$ROOT_DIR/unit_tests" -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Debug

cmake --build "$BUILD_DIR" -j"$(nproc)"

valgrind \
  --tool=memcheck \
  --leak-check=full \
  --show-leak-kinds=all \
  --track-origins=yes \
  --error-exitcode=1 \
  --log-file="$RESULT_FILE" \
  "$TEST_BINARY"

echo "Memcheck analysis completed successfully."
echo "Result: $RESULT_FILE"