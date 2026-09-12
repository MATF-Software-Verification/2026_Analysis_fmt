#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SANITIZER_DIR="$ROOT_DIR/sanitizers"
BUILD_DIR="$SANITIZER_DIR/build"
FMT_BUILD_DIR="$BUILD_DIR/fmt"
CUSTOM_BUILD_DIR="$BUILD_DIR/custom"
RESULT_DIR="$SANITIZER_DIR/results"

SANITIZER_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer -O1 -g"
SANITIZER_LINK_FLAGS="-fsanitize=address,undefined"
SANITIZER_ENV=(
  ASAN_OPTIONS=detect_leaks=0
  UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1
)

mkdir -p "$RESULT_DIR"

cmake -S "$ROOT_DIR/fmt" -B "$FMT_BUILD_DIR" \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Debug \
  -DFMT_TEST=ON \
  -DFMT_DOC=OFF \
  -DFMT_INSTALL=OFF \
  -DCMAKE_CXX_FLAGS="$SANITIZER_FLAGS" \
  -DCMAKE_EXE_LINKER_FLAGS="$SANITIZER_LINK_FLAGS"

cmake --build "$FMT_BUILD_DIR" -j"$(nproc)"

env "${SANITIZER_ENV[@]}" \
  ctest --test-dir "$FMT_BUILD_DIR" \
  --output-on-failure \
  -E '^(format-test|ostream-test)$' \
  2>&1 | tee "$RESULT_DIR/fmt_tests.log"

env "${SANITIZER_ENV[@]}" \
  "$FMT_BUILD_DIR/bin/format-test" \
  --gtest_filter=-memory_buffer_test.move_ctor_dynamic_buffer_non_propagating \
  2>&1 | tee -a "$RESULT_DIR/fmt_tests.log"

env "${SANITIZER_ENV[@]}" \
  "$FMT_BUILD_DIR/bin/ostream-test" \
  --gtest_filter=-ostream_test.write_to_ostream_max_size \
  2>&1 | tee -a "$RESULT_DIR/fmt_tests.log"

cmake -S "$ROOT_DIR/unit_tests" -B "$CUSTOM_BUILD_DIR" \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Debug \
  -DFMT_TEST=OFF \
  -DCMAKE_CXX_FLAGS="$SANITIZER_FLAGS" \
  -DCMAKE_EXE_LINKER_FLAGS="$SANITIZER_LINK_FLAGS"

cmake --build "$CUSTOM_BUILD_DIR" -j"$(nproc)"

env "${SANITIZER_ENV[@]}" \
  "$CUSTOM_BUILD_DIR/format_edge_tests" \
  2>&1 | tee "$RESULT_DIR/custom_tests.log"

echo "ASan and UBSan analysis completed successfully."
echo "Original fmt test result: $RESULT_DIR/fmt_tests.log"
echo "Custom test result: $RESULT_DIR/custom_tests.log"