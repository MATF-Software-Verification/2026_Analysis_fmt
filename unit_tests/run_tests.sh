#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UNIT_DIR="$ROOT_DIR/unit_tests"
BUILD_DIR="$UNIT_DIR/coverage_build"
REPORT_DIR="$UNIT_DIR/coverage_report"

rm -rf "$BUILD_DIR"
rm -rf "$REPORT_DIR"

mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

cmake .. \
  -DCMAKE_CXX_FLAGS="--coverage -O0 -g" \
  -DCMAKE_EXE_LINKER_FLAGS="--coverage"

cmake --build . -j"$(nproc)"

./format_edge_tests

lcov --capture \
  --directory . \
  --output-file coverage.info \
  --ignore-errors mismatch

lcov --remove coverage.info \
  '/usr/*' \
  '*/gtest/*' \
  '*/unit_tests/tests/*' \
  --output-file coverage_fmt.info

lcov --summary coverage_fmt.info

genhtml coverage_fmt.info \
  --output-directory "$REPORT_DIR"

echo
echo "Unit tests and coverage analysis completed."
echo "Coverage report: $REPORT_DIR/index.html"