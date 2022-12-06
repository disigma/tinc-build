cmake_minimum_required(VERSION 3.0)

set(ME_GENERATE_HEADER_SCRIPT ${CMAKE_CURRENT_LIST_FILE})
set(ME_GENERATE_HEADER_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR})

function(me_preprocess input output)
  get_filename_component(name ${output} NAME_WE)
  string(TOUPPER ${name} uppername)
  execute_process(
    COMMAND
      ${CMAKE_CXX_COMPILER} -xc++ -std=c++11 -C -nostdinc -C -DAPI -E ${input}
    OUTPUT_VARIABLE content
  )
  string(REGEX REPLACE "^#" "//#" content "${content}")
  string(REGEX REPLACE "\n*\n" "\n" content "${content}")
  string(REPLACE "\n#" "\n//#" content "${content}")
  file(READ ${input} api_content)
  string(
    CONCAT
      content
      "#ifndef ${uppername}_API_HPP\n#define ${uppername}_API_HPP\n"
      "namespace ${name} { extern const char *MAJOR_VERSION, *MINOR_VERSION, *BUILD_VERSION, *VERSION; }\n"
      "${api_content}\n"
      "${content}\n"
      "#endif // ${uppername}_API_HPP\n"
  )
  file(WRITE ${name}.h.in "${content}")
  configure_file(${name}.h.in ${output} COPYONLY)
endfunction(me_preprocess)

function(me_generate_header input output)
  if(NOT EXISTS ${input})
    return()
  endif()
  if(CMAKE_GENERATOR MATCHES Ninja)
    set(EXTRA_OUTPUT ${ME_PROJECT}-header)
  endif()
  add_custom_command(
    OUTPUT ${output} ${EXTRA_OUTPUT}
    COMMENT "[${ME_PROJECT}] header"
    COMMAND
      ${CMAKE_COMMAND} #
      -D "ME_INPUT=${input}" #
      -D "ME_OUTPUT=${output}" #
      -D "CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}" #
      -P "${ME_GENERATE_HEADER_SCRIPT}"
    DEPENDS ALWAYS
    VERBATIM
  )
endfunction(me_generate_header)

if(NOT CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  return()
endif()

me_preprocess(${ME_INPUT} ${ME_OUTPUT})
