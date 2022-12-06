# Detect the target host configurations.
#
# One of the following variables of the detected target arch will be set:
#
# * <PREFIX>_ARCH_ARM
# * <PREFIX>_ARCH_ARM64
# * <PREFIX>_ARCH_X86
# * <PREFIX>_ARCH_X86_64
#
# Some of the following variables of the detected target os will be set:
#
# * <PREFIX>_OS_ANDROID
# * <PREFIX>_OS_LINUX
# * <PREFIX>_OS_UNIX
# * <PREFIX>_OS_CYGWIN
# * <PREFIX>_OS_WIN
# * <PREFIX>_OS_DARWIN
# * <PREFIX>_OS_IOS
# * <PREFIX>_OS_MAC
#
# Some of the following variables of the detected stdlib os will be set:
#
# * <PREFIX>_USE_LIBSTDCXX
# * <PREFIX>_USE_LIBCXX
# * <PREFIX>_USE_MSVC
# * <PREFIX>_USE_GLIBC
# * <PREFIX>_USE_BIONIC
#
# One of the following variables of the detected endianness will be set:
#
# * <PREFIX>_BIG_ENDIAN
# * <PREFIX>_LITTLE_ENDIAN
#
# A string of the target triplets will be set to the following variable:
#
# * <PREFIX>_TRIPLE
#
# See:
#
# * https://sourceforge.net/p/predef/wiki/Architectures/
# * https://abseil.io/docs/cpp/platforms/macros
function(me_detect_target PREFIX)
  if(${PREFIX}_TRIPLE OR CMAKE_SCRIPT_MODE_FILE)
    return()
  endif()

  include(CheckCSourceCompiles)
  include(CheckCXXSourceCompiles)
  include(TestBigEndian)

  unset(IS_BIG_ENDIAN)
  test_big_endian(IS_BIG_ENDIAN)
  if(IS_BIG_ENDIAN)
    set(${PREFIX}_BIG_ENDIAN ON CACHE BOOL ${PREFIX}_BIG_ENDIAN)
    set(${PREFIX}_LITTLE_ENDIAN OFF CACHE BOOL ${PREFIX}_LITTLE_ENDIAN)
  else()
    set(${PREFIX}_BIG_ENDIAN OFF CACHE BOOL ${PREFIX}_BIG_ENDIAN)
    set(${PREFIX}_LITTLE_ENDIAN ON CACHE BOOL ${PREFIX}_LITTLE_ENDIAN)
  endif()

  unset(ARCH_ARM)
  check_c_source_compiles(
    "
    #if defined(__arm__) || defined(_M_ARM)
    int main() {}
    #endif
    " #
    ARCH_ARM
  )

  unset(ARCH_ARM64)
  check_c_source_compiles(
    "
    #if defined(__aarch64__)
    int main() {}
    #endif
    " #
    ARCH_ARM64
  )

  unset(ARCH_X86)
  check_c_source_compiles(
    "
    #if defined(__i386__) || defined(_M_IX86)
    int main() {}
    #endif
    " #
    ARCH_X86
  )

  unset(ARCH_X86_64)
  check_c_source_compiles(
    "
    #if defined(__x86_64__) || defined(_M_X64)
    int main() {}
    #endif
    " #
    ARCH_X86_64
  )

  unset(OS_ANDROID)
  check_c_source_compiles(
    "
    #if defined(__ANDROID__)
    int main() {}
    #endif
    " #
    OS_ANDROID
  )

  unset(OS_LINUX)
  check_c_source_compiles(
    "
    #if defined(__linux__)
    int main() {}
    #endif
    " #
    OS_LINUX
  )

  unset(OS_UNIX)
  check_c_source_compiles(
    "
    #if defined(__unix__)
    int main() {}
    #endif
    " #
    OS_UNIX
  )

  unset(OS_CYGWIN)
  check_c_source_compiles(
    "
    #if defined(__CYGWIN__)
    int main() {}
    #endif
    " #
    OS_CYGWIN
  )

  unset(OS_WIN)
  check_c_source_compiles(
    "
    #if defined(_WIN32)
    int main() {}
    #endif
    " #
    OS_WIN
  )

  unset(OS_DARWIN)
  check_c_source_compiles(
    "
    #if defined(__APPLE__)
    int main() {}
    #endif
    " #
    OS_DARWIN
  )

  unset(OS_IOS)
  check_c_source_compiles(
    "
    #if defined(__APPLE__)
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
    int main() {}
    #endif
    #endif
    " #
    OS_IOS
  )

  unset(OS_MAC)
  check_c_source_compiles(
    "
    #if defined(__APPLE__)
    #include <TargetConditionals.h>
    #if TARGET_OS_MAC
    int main() {}
    #endif
    #endif
    " #
    OS_MAC
  )

  unset(USE_LIBSTDCXX)
  check_cxx_source_compiles(
    "
    #include <cstdlib>
    #if defined(__GLIBCXX__)
    int main() {}
    #endif
    " #
    USE_LIBSTDCXX
  )

  unset(USE_LIBCXX)
  check_cxx_source_compiles(
    "
    #include <cstdlib>
    #if defined(_LIBCPP_VERSION)
    int main() {}
    #endif
    " #
    USE_LIBCXX
  )

  unset(USE_MSVC)
  check_c_source_compiles(
    "
    #include <cstdlib>
    #if defined(_MSC_VER)
    int main() {}
    #endif
    " #
    USE_MSVC
  )

  unset(USE_GLIBC)
  check_c_source_compiles(
    "
    #include <stdlib.h>
    #if defined(__GLIBC__)
    int main() {}
    #endif
    " #
    USE_GLIBC
  )

  unset(USE_BIONIC)
  check_c_source_compiles(
    "
    #include <stdlib.h>
    #if defined(__BIONIC__)
    int main() {}
    #endif
    " #
    USE_BIONIC
  )

  option(ME_FORCE_64BIT "" ON)

  if(ARCH_ARM AND ARCH_ARM64)
    if(ME_FORCE_64BIT)
      add_compile_options(-arch arm64)
      set(ARCH_ARM OFF)
    else()
      add_compile_options(-arch armv7)
      set(ARCH_ARM64 OFF)
    endif()
  endif()

  if(ARCH_X86 AND ARCH_X86_64)
    if(ME_FORCE_64BIT)
      add_compile_options(-arch x86_64)
      set(ARCH_X86 OFF)
    else()
      add_compile_options(-arch i386)
      set(ARCH_X86_64 OFF)
    endif()
  endif()

  unset(TRIPLE)
  if(ARCH_ARM)
    if(TRIPLE)
      message(FATAL_ERROR "Unsupported target")
    elseif(OS_ANDROID)
      set(TRIPLE armv7-linux-androideabi)
    elseif(OS_IOS)
      set(TRIPLE armv7-apple-darwin)
    else()
      message(FATAL_ERROR "Unsupported target")
    endif()
  endif()

  if(ARCH_ARM64)
    if(TRIPLE)
      message(FATAL_ERROR "Unsupported target")
    elseif(OS_IOS)
      set(TRIPLE aarch64-apple-darwin)
    elseif(OS_ANDROID)
      set(TRIPLE aarch64-linux-android)
    else()
      message(FATAL_ERROR "Unsupported target")
    endif()
  endif()

  if(ARCH_X86)
    if(TRIPLE)
      message(FATAL_ERROR "Unsupported target")
    elseif(OS_ANDROID)
      set(TRIPLE i686-linux-android)
    elseif(OS_DARWIN)
      set(TRIPLE i386-apple-darwin)
    elseif(OS_CYGWIN)
      set(TRIPLE i686-pc-cygwin)
    elseif(OS_LINUX)
      set(TRIPLE i386-linux-gnu)
    else()
      message(FATAL_ERROR "Unsupported target")
    endif()
  endif()

  if(ARCH_X86_64)
    if(TRIPLE)
      message(FATAL_ERROR "Unsupported target")
    elseif(OS_ANDROID)
      set(TRIPLE x86_64-linux-android)
    elseif(OS_DARWIN)
      set(TRIPLE x86_64-apple-darwin)
    elseif(OS_CYGWIN)
      set(TRIPLE x86_64-pc-cygwin)
    elseif(OS_LINUX)
      set(TRIPLE x86_64-linux-gnu)
    endif()
  endif()

  if(NOT TRIPLE)
    message(FATAL_ERROR "Unsupported target")
  endif()

  set(${PREFIX}_ARCH_ARM ${ARCH_ARM} CACHE BOOL ARCH_ARM)
  set(${PREFIX}_ARCH_ARM64 ${ARCH_ARM64} CACHE BOOL ARM_ARM64)
  set(${PREFIX}_ARCH_X86 ${ARCH_X86} CACHE BOOL ARCH_X86)
  set(${PREFIX}_ARCH_X86_64 ${ARCH_X86_64} CACHE BOOL ARCH_X86_64)
  set(${PREFIX}_OS_ANDROID ${OS_ANDROID} CACHE BOOL OS_ANDROID)
  set(${PREFIX}_OS_LINUX ${OS_LINUX} CACHE BOOL OS_LINUX)
  set(${PREFIX}_OS_UNIX ${OS_UNIX} CACHE BOOL OS_UNIX)
  set(${PREFIX}_OS_CYGWIN ${OS_CYGWIN} CACHE BOOL OS_CYGWIN)
  set(${PREFIX}_OS_WIN ${OS_WIN} CACHE BOOL OS_WIN)
  set(${PREFIX}_OS_DARWIN ${OS_DARWIN} CACHE BOOL OS_DARWIN)
  set(${PREFIX}_OS_IOS ${OS_IOS} CACHE BOOL OS_IOS)
  set(${PREFIX}_OS_MAC ${OS_MAC} CACHE BOOL OS_MAC)
  set(${PREFIX}_TRIPLE ${TRIPLE} CACHE STRING TRIPLE)
  set(${PREFIX}_USE_LIBSTDCXX ${USE_LIBSTDCXX} CACHE STRING USE_LIBSTDCXX)
  set(${PREFIX}_USE_LIBCXX ${USE_LIBCXX} CACHE STRING USE_LIBCXX)
  set(${PREFIX}_USE_MSVC ${USE_MSVC} CACHE STRING USE_MSVC)
  set(${PREFIX}_USE_GLIBC ${USE_GLIBC} CACHE STRING USE_GLIBC)
  set(${PREFIX}_USE_BIONIC ${USE_BIONIC} CACHE STRING USE_BIONIC)

  message(STATUS Target: ${${PREFIX}_TRIPLE})
endfunction(me_detect_target)
