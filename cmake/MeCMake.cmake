cmake_minimum_required(VERSION 3.0)

set(ME_CMAKE_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_cmake)
  set(
    X_OPTIONS
    FORCE
    NO_PC
    NO_CC
    NO_CXX
    NO_AR
    NO_NM
    NO_RANLIB
    NO_OBJCOPY
    NO_STRIP
    NO_INSTALL_NAME_TOOL
    NO_CROSS
    NO_CFLAGS
    NO_CXXFLAGS
    NO_SYS
    NO_RPATH
    NO_PREFIX
    NO_SYSROOT
  )
  set(X_SINGLES SOURCE_DIR BUILD_DIR)
  set(X_MULTIS ENV FLAGS DEPENDS CCFLAGS CFLAGS CXXFLAGS)
  cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

  if(X_FORCE)
    list(APPEND X_DEPENDS ALWAYS)
  endif()

  if(NOT X_SOURCE_DIR)
    set(X_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/sources)
  endif()

  if(NOT X_BUILD_DIR)
    set(X_BUILD_DIR ${ME_BUILD_DIR})
  endif()

  if(NOT X_NO_PC)
    list(APPEND X_ENV PKG_CONFIG=${ME_CMAKE_DIR}/pkg-config-static)
  endif()
  if(NOT X_NO_PC AND ME_PKG_CONFIG_DIR)
    list(APPEND X_ENV PKG_CONFIG_LIBDIR=${ME_PKG_CONFIG_DIR})
  endif()
  if(NOT X_NO_CC)
    list(APPEND X_FLAGS -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER})
  endif()
  if(NOT X_NO_CXX)
    list(APPEND X_FLAGS -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER})
  endif()
  if(NOT X_NO_AR)
    list(APPEND X_FLAGS -D CMAKE_AR=${CMAKE_AR})
  endif()
  if(NOT X_NO_NM)
    list(APPEND X_FLAGS -D CMAKE_NM=${CMAKE_NM})
  endif()
  if(NOT X_NO_RANLIB)
    list(APPEND X_FLAGS -D CMAKE_RANLIB=${CMAKE_RANLIB})
  endif()
  if(NOT X_NO_OBJCOPY)
    list(APPEND X_FLAGS -D CMAKE_OBJCOPY=${CMAKE_OBJCOPY})
  endif()
  if(NOT X_NO_STRIP)
    list(APPEND X_FLAGS -D CMAKE_STRIP=${CMAKE_STRIP})
  endif()
  if(NOT X_NO_INSTALL_NAME_TOOL)
    list(APPEND X_FLAGS -D CMAKE_INSTALL_NAME_TOOL=${CMAKE_INSTALL_NAME_TOOL})
  endif()
  if(NOT X_NO_CROSS)
    list(APPEND X_FLAGS -D CMAKE_CROSSCOMPILING=ON)
  endif()
  if(NOT X_NO_RPATH)
    list(APPEND X_FLAGS -D CMAKE_SKIP_BUILD_RPATH=ON)
  endif()

  # Detect build type.
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
  endif()
  string(TOUPPER ${CMAKE_BUILD_TYPE} X_BUILD_TYPE)

  # Set CFLAGS environment.
  unset(CFLAGS)
  foreach(FLAGS ${X_CCFLAGS} ${X_CFLAGS})
    string(CONCAT CFLAGS ${CFLAGS} " " ${FLAGS})
  endforeach()
  if(NOT X_NO_CFLAGS)
    foreach(FLAGS ${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${X_BUILD_TYPE}})
      string(CONCAT CFLAGS ${CFLAGS} " " ${FLAGS})
    endforeach()
  endif()
  list(APPEND X_ENV "CFLAGS=${CFLAGS}")

  # Set CXXFLAGS environment.
  unset(CXXFLAGS)
  foreach(FLAGS ${X_CCFLAGS} ${X_CXXFLAGS})
    string(CONCAT CXXFLAGS ${CXXFLAGS} " " ${FLAGS})
  endforeach()
  if(NOT X_NO_CXXFLAGS)
    foreach(FLAGS ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${X_BUILD_TYPE}})
      string(CONCAT CXXFLAGS ${CXXFLAGS} " " ${FLAGS})
    endforeach()
  endif()
  list(APPEND X_ENV "CXXFLAGS=${CXXFLAGS}")

  if(NOT X_NO_SYS)
    list(APPEND X_FLAGS -D CMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME})
  endif()
  if(NOT X_NO_PREFIX)
    list(APPEND X_FLAGS -D CMAKE_INSTALL_PREFIX=${ME_INSTALL_PREFIX})
  endif()
  if(NOT X_NO_SYSROOT AND ME_SYSROOT)
    list(APPEND X_FLAGS -D CMAKE_OSX_SYSROOT=${ME_SYSROOT})
    list(APPEND X_FLAGS -D CMAKE_FIND_ROOT_PATH=${ME_SYSROOT})
    list(APPEND X_FLAGS -D CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY)
    list(APPEND X_FLAGS -D CMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY)
  endif()
  list(
    APPEND X_FLAGS #
    -D "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}" #
    -G "${CMAKE_GENERATOR}"
  )

  if(CMAKE_GENERATOR STREQUAL Ninja)
    set(ME_MAKEFILE "${X_BUILD_DIR}/build.ninja")
  else()
    set(ME_MAKEFILE "${X_BUILD_DIR}/Makefile")
  endif()
  set(ME_MAKEFILE "${ME_MAKEFILE}" PARENT_SCOPE)

  list(FIND ME_EXTRA_PROJECTS ${ME_PROJECT} PROJECT_INDEX)

  add_custom_command(
    OUTPUT ${ME_MAKEFILE}
    COMMENT "[${ME_PROJECT}] cmake"
    COMMAND
      "${CMAKE_COMMAND}" #
      -D "PROJECT_INDEX=${PROJECT_INDEX}" #
      -D "PROJECT=${ME_PROJECT}" #
      -D "ENVIRONMENTS=${X_ENV}" #
      -D "FLAGS=${X_FLAGS}" #
      -D "SOURCE_DIR=${X_SOURCE_DIR}" #
      -D "BUILD_DIR=${X_BUILD_DIR}" #
      -P "${ME_CMAKE_SCRIPT}"
    DEPENDS ${X_DEPENDS} ${X_SOURCE_DIR}/CMakeLists.txt
    VERBATIM
  )
endfunction(me_cmake)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  return()
elseif(NOT $ENV{ALL}x STREQUAL 1x)
  return()
elseif($ENV{FAST}x STREQUAL 1x AND PROJECT_INDEX EQUAL -1)
  return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/MeExports.cmake)
me_exports(${PROJECT} ${ENVIRONMENTS})

if($ENV{DEBUG}x STREQUAL 1x OR $ENV{VERBOSE}x STREQUAL 1x)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E echo #
      [${PROJECT}] ${CMAKE_COMMAND} ${FLAGS} ${SOURCE_DIR}
  )
endif()

file(MAKE_DIRECTORY ${BUILD_DIR})

unset(OUTPUT_REDIRECT)
set(ERROR_MESSAGE "cmake failed:\n")
if(NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT OUTPUT_FILE cmake.stdout)
  list(APPEND ERROR_MESSAGE "STDOUT: ${BUILD_DIR}/cmake.stdout\n")
endif()
if(NOT $ENV{DEBUG}x STREQUAL 1x AND NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT ERROR_FILE cmake.stderr)
  list(APPEND ERROR_MESSAGE "STDERR: ${BUILD_DIR}/cmake.stderr\n")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} ${FLAGS} ${SOURCE_DIR} ${OUTPUT_REDIRECT}
  RESULT_VARIABLE error #
  WORKING_DIRECTORY ${BUILD_DIR}
)
if(error)
  message(FATAL_ERROR ${ERROR_MESSAGE})
endif()
