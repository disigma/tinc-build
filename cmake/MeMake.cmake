cmake_minimum_required(VERSION 3.0)

set(ME_MAKE_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_make)
  set(X_OPTIONS KEEP_LIBTOOL_ARCHIVES)
  set(X_SINGLES OUTPUT BUILD_DIR)
  set(X_MULTIS TARGETS DEPENDS)
  cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

  if(NOT X_BUILD_DIR)
    set(X_BUILD_DIR "${ME_BUILD_DIR}")
  endif()

  if(NOT X_TARGETS)
    set(X_TARGETS install)
  endif()

  if(NOT X_OUTPUT)
    set(X_OUTPUT make)
  endif()

  if(X_KEEP_LIBTOOL_ARCHIVES)
    set(X_KEEP_LIBTOOL_ARCHIVES ON)
  else()
    set(X_KEEP_LIBTOOL_ARCHIVES OFF)
  endif()

  list(FIND ME_EXTRA_PROJECTS ${ME_PROJECT} PROJECT_INDEX)

  add_custom_command(
    OUTPUT ${X_OUTPUT} ${${ME_PROJECT}-LIBS}
    COMMENT "[${ME_PROJECT}] make"
    COMMAND
      ${CMAKE_COMMAND} #
      -D "CMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}" #
      -D "PROJECT_INDEX=${PROJECT_INDEX}" #
      -D "TARGETS=${X_TARGETS}" #
      -D "BUILD_DIR=${X_BUILD_DIR}" #
      -D "INSTALL_PREFIX=${ME_INSTALL_PREFIX}" #
      -D "KEEP_LIBTOOL_ARCHIVES=${X_KEEP_LIBTOOL_ARCHIVES}" #
      -P "${ME_MAKE_SCRIPT}"
    DEPENDS ${X_DEPENDS} "${ME_MAKEFILE}"
    WORKING_DIRECTORY "${X_BUILD_DIR}"
    VERBATIM
  )
endfunction(me_make)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  return()
elseif(NOT $ENV{ALL}x STREQUAL 1x)
  return()
elseif($ENV{FAST}x STREQUAL 1x AND PROJECT_INDEX EQUAL -1)
  return()
endif()

unset(OUTPUT_REDIRECT)
set(ERROR_MESSAGE "make failed:\n")
if(NOT $ENV{VERBOSE}x STREQUAL 1x)
  list(APPEND OUTPUT_REDIRECT OUTPUT_FILE make.stdout)
  list(APPEND ERROR_MESSAGE "STDOUT: ${BUILD_DIR}/make.stdout\n")
endif()
execute_process(
  COMMAND ${CMAKE_MAKE_PROGRAM} ${TARGETS} ${OUTPUT_REDIRECT} #
  RESULT_VARIABLE error #
  WORKING_DIRECTORY ${BUILD_DIR}
)
if(error)
  message(FATAL_ERROR ${ERROR_MESSAGE})
endif()

# remove libtool archives
if(NOT KEEP_LIBTOOL_ARCHIVES)
  file(GLOB_RECURSE LIBTOOL_ARCHIVES ${INSTALL_PREFIX}/lib/*.la)
  foreach(archive ${LIBTOOL_ARCHIVES})
    file(REMOVE ${archive})
  endforeach()
endif()
