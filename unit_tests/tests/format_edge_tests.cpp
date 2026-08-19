#include <climits>
#include <limits>
#include <string>

#include "fmt/format.h"
#include "gtest/gtest.h"

TEST(FormatEdgeTests, IntegerLimits) {
  EXPECT_EQ(fmt::format("{}", INT_MAX), std::to_string(INT_MAX));
  EXPECT_EQ(fmt::format("{}", INT_MIN), std::to_string(INT_MIN));
}

TEST(FormatEdgeTests, HexPadding) {
  EXPECT_EQ(fmt::format("{:08x}", 255), "000000ff");
}

TEST(FormatEdgeTests, FloatingPointSpecialValues) {
  const double inf = std::numeric_limits<double>::infinity();
  const double nan = std::numeric_limits<double>::quiet_NaN();

  EXPECT_EQ(fmt::format("{}", inf), "inf");
  EXPECT_EQ(fmt::format("{}", -inf), "-inf");
  EXPECT_EQ(fmt::format("{}", nan), "nan");
}

TEST(FormatEdgeTests, PrecisionAndRounding) {
  EXPECT_EQ(fmt::format("{:.2f}", 12.345), "12.35");
  EXPECT_EQ(fmt::format("{:.3f}", 1.23456), "1.235");
}

TEST(FormatEdgeTests, InvalidRuntimeFormatThrows) {
  EXPECT_THROW(
      fmt::format(fmt::runtime("{:.2f"), 12.34),
      fmt::format_error);
}

int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
