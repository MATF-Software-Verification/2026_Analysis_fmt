#include <cstddef>
#include <cstdint>
#include <cstring>
#include <string>
#include <fmt/format.h>

template <typename T>
T read_value(const uint8_t* data) {
  T value{};
  std::memcpy(&value, data, sizeof(T));
  return value;
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  if (size < 2) {
    return 0;
  }

  const uint8_t type = data[0] % 4;

  try {
    switch (type) {
      case 0: { // int
        if (size < 1 + sizeof(int)) {
          return 0;
        }

        const uint8_t* value_data = data + 1;
        int value = read_value<int>(value_data);

        const char* format_data =
            reinterpret_cast<const char*>(data + 1 + sizeof(int));

        const size_t format_size =
            size - 1 - sizeof(int);

        std::string format_str(format_data, format_size);

        (void)fmt::format(
            fmt::runtime(format_str),
            value
        );

        break;
      }

      case 1: { // unsigned int
        if (size < 1 + sizeof(unsigned int)) {
          return 0;
        }

        const uint8_t* value_data = data + 1;
        unsigned int value =
            read_value<unsigned int>(value_data);

        const char* format_data =
            reinterpret_cast<const char*>(
                data + 1 + sizeof(unsigned int)
            );

        const size_t format_size =
            size - 1 - sizeof(unsigned int);

        std::string format_str(format_data, format_size);

        (void)fmt::format(
            fmt::runtime(format_str),
            value
        );

        break;
      }

      case 2: { // double
        if (size < 1 + sizeof(double)) {
          return 0;
        }

        const uint8_t* value_data = data + 1;
        double value = read_value<double>(value_data);

        const char* format_data =
            reinterpret_cast<const char*>(
                data + 1 + sizeof(double)
            );

        const size_t format_size =
            size - 1 - sizeof(double);

        std::string format_str(format_data, format_size);

        (void)fmt::format(
            fmt::runtime(format_str),
            value
        );

        break;
      }

      case 3: { // std::string
        const size_t string_length = data[1] % 33;

        if (size < 2 + string_length) {
          return 0;
        }

        std::string value(
            reinterpret_cast<const char*>(data + 2),
            string_length
        );

        const char* format_data =
            reinterpret_cast<const char*>(
                data + 2 + string_length
            );

        const size_t format_size =
            size - 2 - string_length;

        std::string format_str(
            format_data,
            format_size
        );

        (void)fmt::format(
            fmt::runtime(format_str),
            value
        );

        break;
      }
    }

  } catch (const fmt::format_error&) {
    // Invalid format strings are expected during fuzzing.
  }

  return 0;
}