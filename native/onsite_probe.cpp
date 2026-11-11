// OnSiteSuite 2.0 native auxiliary probe (MIT); no external dependencies.
// Read-only; no administrative privileges or network connectivity required.
#include <cstdint>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#else
#include <unistd.h>
#endif

namespace {
std::string json_escape(std::string_view s) {
  std::ostringstream out;
  const char *hex = "0123456789abcdef";
  out << '"';
  for (unsigned char c : s) {
    switch (c) {
      case '"': out << "\\\""; break;
      case '\\': out << "\\\\"; break;
      case '\b': out << "\\b"; break;
      case '\f': out << "\\f"; break;
      case '\n': out << "\\n"; break;
      case '\r': out << "\\r"; break;
      case '\t': out << "\\t"; break;
      default:
        if (c < 0x20) {
          out << "\\u00" << hex[(c >> 4) & 0xf] << hex[c & 0xf];
        } else { out << c; }
    }
  }
  out << '"';
  return out.str();
}
std::string hostname() {
#ifdef _WIN32
  char buffer[256]{};
  DWORD size = static_cast<DWORD>(sizeof(buffer));
  return GetComputerNameA(buffer, &size) ? std::string(buffer, size) : "unknown";
#else
  char buffer[256]{};
  return ::gethostname(buffer, sizeof(buffer)) == 0 ? std::string(buffer) : "unknown";
#endif
}
std::string after_colon(const std::string &line) {
  auto pos = line.find(':');
  if (pos == std::string::npos) return {};
  auto value = line.substr(pos + 1);
  auto first = value.find_first_not_of(" \t");
  return first == std::string::npos ? "" : value.substr(first);
}
uint64_t mem_field(std::string_view prefix) {
#ifndef _WIN32
  std::ifstream file("/proc/meminfo");
  std::string line;
  while (std::getline(file, line)) {
    if (line.rfind(prefix.data(), 0) == 0) {
      std::istringstream in(after_colon(line));
      uint64_t value = 0;
      in >> value;
      return value;
    }
  }
#else
  (void)prefix;
#endif
  return 0;
}
std::string cpu_model() {
#ifndef _WIN32
  std::ifstream file("/proc/cpuinfo");
  std::string line;
  while (std::getline(file, line)) {
    if (line.rfind("model name", 0) == 0 || line.rfind("Hardware", 0) == 0) return after_colon(line);
  }
#endif
  return {};
}
} // namespace
int main(int argc, char **argv) {
  if (argc > 1 && std::string_view(argv[1]) == "--version") {
    std::cout << "onsite-probe 2.0.0\n";
    return 0;
  }
  if (argc > 1 && std::string_view(argv[1]) != "--json") {
    std::cerr << "Usage: onsite-probe [--json|--version]\n";
    return 2;
  }
#ifdef _WIN32
  constexpr std::string_view platform = "windows";
#else
  constexpr std::string_view platform = "linux";
#endif
  std::cout << "{\"schemaVersion\":\"2.0\",\"component\":\"onsite-probe\",\"platform\":"
            << json_escape(platform) << ",\"hostname\":" << json_escape(hostname())
            << ",\"cpuModel\":" << json_escape(cpu_model())
            << ",\"memTotalKiB\":" << mem_field("MemTotal:")
            << ",\"memAvailableKiB\":" << mem_field("MemAvailable:") << "}\n";
  return 0;
}
