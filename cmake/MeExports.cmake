cmake_minimum_required(VERSION 3.0)

# Export environment variables.
function(me_exports project)
  foreach(env ${ARGN})
    string(REGEX MATCH ^[^=]+ key "${env}")
    string(LENGTH "${key}=" length)
    string(SUBSTRING "${env}" ${length} -1 value)
    set(ENV{${key}} "${value}")
    list(APPEND ENV_EXPORTS "${key}=${value}")
    if($ENV{VERBOSE}x STREQUAL 1x)
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E echo "[${project}]" ${key} : "${value}"
      )
    endif()
  endforeach()
  set(ENV_EXPORTS "${ENV_EXPORTS}" PARENT_SCOPE)
endfunction()
