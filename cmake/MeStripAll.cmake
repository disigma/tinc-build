if(NOT CMAKE_SCRIPT_MODE_FILE)
  add_custom_target(
    strip-all
    DEPENDS install-all
    COMMAND
      ${CMAKE_COMMAND} #
      -D "PREFIX=${CMAKE_INSTALL_PREFIX}" #
      -D "OBJCOPY=${CMAKE_OBJCOPY}" #
      -P "${CMAKE_CURRENT_LIST_FILE}" #
    VERBATIM
  )
endif()

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  return()
endif()

file(GLOB binaries RELATIVE ${PREFIX}/bin/ ${PREFIX}/bin/*)

if(NOT OBJCOPY)
  find_program(OBJCOPY objcopy llvm-objcopy)
endif()

if(NOT OBJCOPY OR OBJCOPY STREQUAL OBJCOPY-NOTFOUND)
  message(FATAL_ERROR "objcopy not found")
else()
  message(STATUS "Found objcopy: ${OBJCOPY}")
endif()

file(MAKE_DIRECTORY ${PREFIX}/dbg)

foreach(binary ${binaries})
  set(file ${PREFIX}/bin/${binary})
  if(IS_DIRECTORY ${file} OR IS_SYMLINK ${file})
    continue()
  endif()
  message(STATUS "Strip: ${file}")
  execute_process(
    COMMAND ${OBJCOPY} --only-keep-debug ${file} ${PREFIX}/dbg/${binary}.dbg
  )
  execute_process(COMMAND ${OBJCOPY} --strip-all ${file})
  execute_process(COMMAND ${OBJCOPY} --remove-section .gnu_debuglink ${file})
endforeach()
