cmake_minimum_required(VERSION 3.0)

set(ME_AUTOCONF_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_autoconf)
  set(X_OPTIONS FORCE)
  set(X_SINGLES SOURCE_DIR)
  set(X_MULTIS ENV FLAGS DEPENDS)
  cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

  if(NOT X_SOURCE_DIR)
    set(X_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/sources)
  endif()

  if(NOT X_FLAGS)
    set(X_FLAGS -if --warnings=none)
  endif()

  if(X_FORCE)
    list(APPEND X_DEPENDS ALWAYS)
  endif()

  find_program(AUTORECONF autoreconf)
  if(AUTORECONF-NOTFOUND)
    message(FATAL_ERROR "autoreconf not found")
  endif()

  # Preferred to use glibtoolize on OSX
  find_program(LIBTOOLIZE NAMES glibtoolize libtoolize)
  if(LIBTOOLIZE-NOTFOUND)
    message(FATAL_ERROR "libtoolize not found")
  endif()
  list(APPEND X_ENV LIBTOOLIZE=${LIBTOOLIZE})

  list(FIND ME_EXTRA_PROJECTS ${ME_PROJECT} PROJECT_INDEX)

  add_custom_command(
    OUTPUT ${X_SOURCE_DIR}/configure
    COMMENT "[${ME_PROJECT}] autoconf"
    COMMAND
      ${CMAKE_COMMAND} #
      -D "PROJECT_INDEX=${PROJECT_INDEX}" #
      -D "PROJECT=${ME_PROJECT}" #
      -D "ENVIRONMENTS=${X_ENV}" #
      -D "PROGRAM=${AUTORECONF}" #
      -D "FLAGS=${X_FLAGS}" #
      -D "BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}" #
      -P "${ME_AUTOCONF_SCRIPT}"
    WORKING_DIRECTORY ${X_SOURCE_DIR}
    DEPENDS ${X_DEPENDS}
    VERBATIM
  )
endfunction()

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
    COMMAND ${CMAKE_COMMAND} -E echo [${PROJECT}] ${PROGRAM} ${FLAGS}
  )
endif()

unset(OUTPUT_REDIRECT)
set(ERROR_MESSAGE "autoconf failed:\n")
if(NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT OUTPUT_FILE ${BUILD_DIR}/autoconf.stdout)
  list(APPEND ERROR_MESSAGE "STDOUT: ${BUILD_DIR}/autoconf.stdout\n")
endif()
if(NOT $ENV{DEBUG}x STREQUAL 1x AND NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT ERROR_FILE ${BUILD_DIR}/autoconf.stderr)
  list(APPEND ERROR_MESSAGE "STDERR: ${BUILD_DIR}/autoconf.stderr\n")
endif()

execute_process(
  COMMAND ${PROGRAM} ${FLAGS} ${OUTPUT_REDIRECT} #
  RESULT_VARIABLE error
)
if(error)
  message(FATAL_ERROR ${ERROR_MESSAGE})
endif()
