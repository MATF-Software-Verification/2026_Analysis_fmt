#include <cstddef>
#include <string>

#include "fmt/format.h"

int main() {
    constexpr int iterations = 10'000'000;
  std::size_t checksum = 0;

  for (int i = 0; i < iterations; ++i) {
    const std::string integer_result =
        fmt::format("id={:08d}", i);

    const std::string floating_result =
        fmt::format("value={:.6f}",
                    static_cast<double>(i) / 3.0);

    const std::string text_result =
        fmt::format("name={:<16} count={}", "fmt", i);

    checksum += integer_result.size();
    checksum += floating_result.size();
    checksum += text_result.size();
  }

  fmt::print("checksum={}\n", checksum);
  return 0;
}