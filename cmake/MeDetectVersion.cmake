function(me_detect_version)
  find_package(Git)
  if(GIT_FOUND)
    execute_process(
      COMMAND git rev-parse --short --verify HEAD #
      WORKING_DIRECTORY ${ME_ROOT_DIR} #
      OUTPUT_VARIABLE ME_BUILD_VERSION #
      RESULT_VARIABLE result #
      ERROR_QUIET #
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(result)
      set(ME_BUILD_VERSION 0 PARENT_SCOPE)
    endif()
  else()
    set(ME_BUILD_VERSION 0)
  endif()

  string(TIMESTAMP ME_MINOR_VERSION "%Y%m%d")

  set(ME_MINOR_VERSION ${ME_MINOR_VERSION} CACHE STRING ME_MINOR_VERSION FORCE)
  set(ME_BUILD_VERSION ${ME_BUILD_VERSION} CACHE STRING ME_MINOR_VERSION FORCE)
endfunction(me_detect_version)
