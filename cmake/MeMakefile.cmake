cmake_minimum_required(VERSION 3.0)

function(me_makefile_make target)
  if(NOT TARGET)
    set(TARGET x64-linux)
  endif()

  if(NOT BUILD_TYPE)
    set(BUILD_TYPE Debug)
  endif()

  string(TOLOWER ${BUILD_TYPE} BUILD_TYPE_NAME)
  if(BUILD_TYPE_NAME STREQUAL relwithdebinfo)
    set(BUILD_TYPE_NAME release)
  endif()
  set(TARGET_DIR ${ME_ROOT_DIR}/target/${TARGET}-${BUILD_TYPE_NAME})
  set(BUILD_DIR ${ME_ROOT_DIR}/build/${TARGET}-${BUILD_TYPE_NAME})

  if(CLEAN)
    if(target STREQUAL strip-all)
      set(DISTCLEAN ON)
    else()
      message(STATUS "Clear directory ${BUILD_DIR}/${target}")
      file(REMOVE_RECURSE ${BUILD_DIR}/${target})
      return()
    endif()
  endif()

  if(DISTCLEAN)
    message(STATUS "Clear directory ${BUILD_DIR}")
    file(REMOVE_RECURSE ${BUILD_DIR})
    return()
  endif()

  file(MAKE_DIRECTORY ${BUILD_DIR})

  if(target STREQUAL strip-all)
    set(ENV{ALL} 1)
  endif()

  find_program(Ninja NAMES ninja ninja-build)

  if(Ninja STREQUAL Ninja-NOTFOUND)
    message(STATUS "Ninja not found, use make instead.")
  else()
    message(STATUS "Found Ninja: ${Ninja}")
    set(ME_GENERATOR -GNinja)
  endif()

  if(NOT DEFINED ENV{NO_REDIR})
    get_filename_component(STDOUT /proc/self/fd/1 REALPATH)
    if(EXISTS ${STDOUT})
      set(OUTPUT_FILE OUTPUT_FILE ${STDOUT})
    endif()
  endif()

  include(MeWimal)
  set(ENV{WIMAL_HOME} "${WIMAL_HOME}")

  execute_process(
    COMMAND
      ${CMAKE_COMMAND} ${ME_GENERATOR} #
      -D "CMAKE_TOOLCHAIN_FILE=${ME_CMAKE_DIR}/MeToolchain.cmake" #
      -D "WIMAL_TARGET=${TARGET}" #
      -D "CMAKE_BUILD_TYPE=${BUILD_TYPE}" #
      -D "CMAKE_INSTALL_PREFIX=${TARGET_DIR}" #
      -D "ME_EXTRA_PROJECTS=${target}" #
      ${ME_ROOT_DIR} ${OUTPUT_FILE}
    WORKING_DIRECTORY ${BUILD_DIR}
    RESULT_VARIABLE SUCCESS
  )
  if(NOT SUCCESS EQUAL 0)
    message(FATAL_ERROR "Failed to configure cmake project")
  endif()

  if(NOT target STREQUAL strip-all)
    if(ME_INSTALL)
      set(target install-${target})
    else()
      set(target ${target}-)
    endif()
  endif()

  find_program(Wimal NAMES wimal PATHS "${WIMAL_HOME}/bin" NO_DEFAULT_PATH)
  if(NOT Wimal STREQUAL Wimal-NOTFOUND)
    if(DEFINED ENV{NO_BEAR})
      message(STATUS "Bear Off: ${Wimal}")
    else()
      message(STATUS "Bear On: ${Wimal}")
      set(BEAR_COMMAND ${Wimal} bear)
    endif()
  else()
    message(STATUS "Wimal Missing")
  endif()

  execute_process(
    COMMAND
      ${BEAR_COMMAND} ${CMAKE_COMMAND} --build ${BUILD_DIR} --target ${target}
      ${OUTPUT_FILE}
    RESULT_VARIABLE SUCCESS
  )
  if(NOT SUCCESS EQUAL 0)
    message(FATAL_ERROR "Failed to build project")
  endif()
endfunction(me_makefile_make)
