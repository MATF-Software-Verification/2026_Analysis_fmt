cmake_minimum_required(VERSION 3.16)
project(fmt_unit_tests LANGUAGES CXX)

enable_testing()

add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/../fmt
  ${CMAKE_CURRENT_BINARY_DIR}/fmt-build
)

add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/../fmt/test/gtest
  ${CMAKE_CURRENT_BINARY_DIR}/gtest-build
)

add_executable(format_edge_tests
  tests/format_edge_tests.cpp
)

target_link_libraries(format_edge_tests
  PRIVATE
  fmt
  gtest
)

add_test(
  NAME format_edge_tests
  COMMAND format_edge_tests
)