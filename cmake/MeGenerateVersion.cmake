cmake_minimum_required(VERSION 3.0)

set(ME_GENERATE_VERSION_SCRIPT ${CMAKE_CURRENT_LIST_FILE})

function(me_generate_version output name major minor build)
  if(CMAKE_GENERATOR MATCHES Ninja)
    set(EXTRA_OUTPUT ${ME_PROJECT}-version)
  endif()
  add_custom_command(
    OUTPUT ${output} ${EXTRA_OUTPUT}
    COMMENT "[${ME_PROJECT}] version"
    COMMAND
      ${CMAKE_COMMAND} #
      -D "ME_NAME=${name}" #
      -D "ME_MAJOR=${major}" #
      -D "ME_MINOR=${minor}" #
      -D "ME_BUILD=${build}" #
      -D "ME_FULL=${major}.${minor}.${build}" #
      -D "ME_OUTPUT=${output}" #
      -P "${ME_GENERATE_VERSION_SCRIPT}"
    DEPENDS ALWAYS
  )
endfunction(me_generate_version)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  return()
endif()

file(
  WRITE version.cpp.in
  "
  namespace \@ME_NAME\@ {
    const char *MAJOR_VERSION = \"\@ME_MAJOR\@\";
    const char *MINOR_VERSION = \"\@ME_MINOR\@\";
    const char *BUILD_VERSION = \"\@ME_BUILD\@\";
    const char *VERSION = \"\@ME_FULL\@\";
  }
  "
)
configure_file(version.cpp.in ${ME_OUTPUT} @ONLY)
