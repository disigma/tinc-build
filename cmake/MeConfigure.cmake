cmake_minimum_required(VERSION 3.0)

set(ME_CONFIGURE_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_configure)
  set(
    X_OPTIONS
    FORCE
    NO_FLAGS
    NO_PC
    NO_CC
    NO_CXX
    NO_AR
    NO_NM
    NO_RANLIB
    NO_OBJCOPY
    NO_STRIP
    NO_CFLAGS
    NO_CXXFLAGS
    NO_PREFIX
    NO_HOST
    NO_PIC
    NO_SYSROOT
    NO_STATIC
    NO_INLINE_ENV
  )
  set(X_SINGLES BUILD_DIR FILE)
  set(X_MULTIS ENV FLAGS DEPENDS CCFLAGS CFLAGS CXXFLAGS)
  cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

  if(X_FORCE)
    list(APPEND X_DEPENDS ALWAYS)
  endif()

  if(NOT X_BUILD_DIR)
    set(X_BUILD_DIR ${ME_BUILD_DIR})
  endif()

  if(NOT X_FILE)
    set(X_FILE ${CMAKE_CURRENT_SOURCE_DIR}/sources/configure)
  endif()

  if(NOT X_NO_PC)
    list(APPEND X_ENV PKG_CONFIG=${ME_CMAKE_DIR}/pkg-config-static)
  endif()
  if(NOT X_NO_PC AND ME_PKG_CONFIG_DIR)
    list(APPEND X_ENV PKG_CONFIG_LIBDIR=${ME_PKG_CONFIG_DIR})
  endif()
  if(NOT X_NO_CC)
    list(APPEND X_ENV CC=${CMAKE_C_COMPILER})
  endif()
  if(NOT X_NO_CXX)
    list(APPEND X_ENV CXX=${CMAKE_CXX_COMPILER})
  endif()
  if(NOT X_NO_AR)
    list(APPEND X_ENV AR=${CMAKE_AR})
  endif()
  if(NOT X_NO_NM)
    list(APPEND X_ENV NM=${CMAKE_NM})
  endif()
  if(NOT X_NO_RANLIB)
    list(APPEND X_ENV RANLIB=${CMAKE_RANLIB})
  endif()
  if(NOT X_NO_OBJCOPY)
    list(APPEND X_ENV OBJCOPY=${CMAKE_OBJCOPY})
  endif()
  if(NOT X_NO_STRIP)
    list(APPEND X_ENV STRIP=${CMAKE_STRIP})
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
    list(APPEND X_ENV "CXXFLAGS=${CXXFLAGS}")
  endif()

  if(NOT X_NO_FLAGS)
    if(NOT X_NO_PREFIX)
      list(APPEND X_FLAGS --prefix=${ME_INSTALL_PREFIX})
    endif()
    if(NOT X_NO_HOST)
      list(APPEND X_FLAGS --host=${ME_TRIPLE})
    endif()
    if(NOT X_NO_PIC)
      list(APPEND X_FLAGS --with-pic)
    endif()
    if(NOT X_NO_SYSROOT AND ME_SYSROOT)
      list(APPEND X_FLAGS --with-sysroot=${ME_SYSROOT})
    endif()
    if(NOT X_NO_STATIC)
      list(APPEND X_FLAGS --enable-static --disable-shared)
    endif()
  endif()

  set(ME_MAKEFILE ${X_BUILD_DIR}/Makefile)
  set(ME_MAKEFILE ${ME_MAKEFILE} PARENT_SCOPE)

  list(FIND ME_EXTRA_PROJECTS ${ME_PROJECT} PROJECT_INDEX)

  add_custom_command(
    OUTPUT ${ME_MAKEFILE}
    COMMENT "[${ME_PROJECT}] configure"
    COMMAND
      ${CMAKE_COMMAND} #
      -D "PROJECT_INDEX=${PROJECT_INDEX}" #
      -D "PROJECT=${ME_PROJECT}" #
      -D "ENVIRONMENTS=${X_ENV}" #
      -D "FILE=${X_FILE}" #
      -D "FLAGS=${X_FLAGS}" #
      -D "BUILD_DIR=${X_BUILD_DIR}" #
      -D "NO_INLINE_ENV=${X_NO_INLINE_ENV}" #
      -P "${ME_CONFIGURE_SCRIPT}"
    DEPENDS ${X_DEPENDS} ${X_FILE}
    VERBATIM
  )
  set(CMAKE_MAKE_PROGRAM make PARENT_SCOPE)
endfunction(me_configure)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  return()
elseif(NOT $ENV{ALL}x STREQUAL 1x)
  return()
elseif($ENV{FAST}x STREQUAL 1x AND PROJECT_INDEX EQUAL -1)
  return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/MeExports.cmake)
me_exports(${PROJECT} ${ENVIRONMENTS})

# Avoid environment variables being lost.
# https://www.gnu.org/software/autoconf/manual/autoconf-2.65/html_node/Defining-
# Variables.html
if(NO_INLINE_ENV)
  unset(ENV_EXPORTS)
endif()

if($ENV{DEBUG}x STREQUAL 1x OR $ENV{VERBOSE}x STREQUAL 1x)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E echo #
      [${PROJECT}] ${CMAKE_COMMAND} ${FLAGS} ${SOURCE_DIR}
  )
endif()

file(MAKE_DIRECTORY ${BUILD_DIR})

unset(OUTPUT_REDIRECT)
set(ERROR_MESSAGE "configure failed:\n")
if(NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT OUTPUT_FILE configure.stdout)
  list(APPEND ERROR_MESSAGE "STDOUT: ${BUILD_DIR}/configure.stdout\n")
endif()
if(NOT $ENV{DEBUG}x STREQUAL 1x AND NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT ERROR_FILE configure.stderr)
  list(APPEND ERROR_MESSAGE "STDERR: ${BUILD_DIR}/configure.stderr\n")
endif()

execute_process(
  COMMAND ${FILE} ${FLAGS} ${ENV_EXPORTS} ${OUTPUT_REDIRECT}
  RESULT_VARIABLE error #
  WORKING_DIRECTORY ${BUILD_DIR}
)
if(error)
  message(FATAL_ERROR ${ERROR_MESSAGE})
endif()
