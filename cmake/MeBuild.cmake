function(me_install_target target)
  if(TARGET install-${target})
    return()
  endif()
  if(NOT TARGET install-all)
    add_custom_target(install-all)
    add_custom_target(install-all-stripped)
  endif()
  add_custom_target(
    install-${target}
    DEPENDS ${target}- #
    COMMENT "[${target}] install" #
    COMMAND
      ${CMAKE_COMMAND} #
      -D "CMAKE_INSTALL_COMPONENT=${target}" #
      -P "${CMAKE_BINARY_DIR}/cmake_install.cmake"
    VERBATIM
  )
  add_custom_target(
    install-${target}-stripped
    DEPENDS ${target}-
    COMMENT "[${target}-stripped] install"
    COMMAND
      ${CMAKE_COMMAND} #
      -D "CMAKE_INSTALL_COMPONENT=${target}" #
      -D "CMAKE_INSTALL_DO_STRIP=1" #
      -P "${CMAKE_BINARY_DIR}/cmake_install.cmake"
    VERBATIM
  )
  add_dependencies(install-all install-${target})
  add_dependencies(install-all-stripped install-${target}-stripped)
endfunction(me_install_target)

function(me_build_lib)
  file(
    GLOB_RECURSE
    sources
    ${ME_SOURCE_DIR}/*.c
    ${ME_SOURCE_DIR}/*.cc
    ${ME_SOURCE_DIR}/*.cpp
    ${ME_SOURCE_DIR}/*.m
    ${ME_SOURCE_DIR}/*.mm
  )
  list(
    REMOVE_ITEM sources #
    ${ME_SOURCE_DIR}/main.c #
    ${ME_SOURCE_DIR}/main.cpp #
    ${ME_SOURCE_DIR}/dllmain.c #
    ${ME_SOURCE_DIR}/dllmain.cpp
  )

  set(version_file ${ME_BUILD_DIR}/version.cpp)
  me_generate_version(
    ${version_file} ${ME_PROJECT_NAME} ${ME_PROJECT_VERSION}
    ${ME_MINOR_VERSION} ${ME_BUILD_VERSION}
  )
  list(APPEND sources ${version_file})

  if(EXISTS ${ME_SOURCE_DIR}/api.hpp)
    set(
      header_file
      ${ME_BUILD_DIR}/include/${ME_PROJECT_NAME}/${ME_PROJECT_NAME}.h
    )
    me_generate_header(${ME_SOURCE_DIR}/api.hpp ${header_file})
    list(APPEND sources ${header_file})
    include_directories(${ME_BUILD_DIR}/include)
  endif()

  add_library(${ME_PROJECT} ${sources})
  set_target_properties(${ME_PROJECT} PROPERTIES OUTPUT_NAME ${ME_PROJECT_NAME})
endfunction(me_build_lib)

function(me_build_dll)
  if(EXISTS ${ME_SOURCE_DIR}/dllmain.cpp)
    add_library(${ME_PROJECT}-dll SHARED ${ME_SOURCE_DIR}/dllmain.cpp)
    target_link_libraries(${ME_PROJECT}-dll ${ME_PROJECT})
    set_target_properties(
      ${ME_PROJECT}-dll PROPERTIES OUTPUT_NAME ${ME_PROJECT_NAME}
    )
    install(TARGETS ${ME_PROJECT}-dll COMPONENT ${ME_PROJECT} DESTINATION bin)
    me_install_target(${ME_PROJECT})
  endif()
endfunction(me_build_dll)

function(me_build_exe)
  if(EXISTS ${ME_SOURCE_DIR}/main.cpp)
    add_executable(${ME_PROJECT}-exe ${ME_SOURCE_DIR}/main.cpp)
    target_link_libraries(${ME_PROJECT}-exe ${ME_PROJECT})
    set_target_properties(
      ${ME_PROJECT}-exe PROPERTIES OUTPUT_NAME ${ME_PROJECT_NAME}
    )
    install(TARGETS ${ME_PROJECT}-exe COMPONENT ${ME_PROJECT} DESTINATION bin)
    me_install_target(${ME_PROJECT})
  endif()
endfunction(me_build_exe)

function(me_build_test)
  file(GLOB_RECURSE sources ${ME_TEST_DIR}/*.cpp ${ME_TEST_DIR}/*.c)
  list(LENGTH sources count)
  if(count EQUAL 0)
    return()
  endif()
  list(APPEND X_TEST_DEPENDS main.gtest-1.10.0)
  me_import(${X_TEST_DEPENDS})
  add_executable(${ME_PROJECT}-test EXCLUDE_FROM_ALL ${sources})
  set_target_properties(
    ${ME_PROJECT}-test PROPERTIES OUTPUT_NAME ${ME_PROJECT_NAME}.test
  )
  target_link_libraries(
    ${ME_PROJECT}-test ${ME_PROJECT} ${X_TEST_DEPENDS} ${X_TEST_LIBS}
  )
  target_include_directories(${ME_PROJECT}-test PUBLIC ${ME_IMPORTED_INCLUDES})
endfunction(me_build_test)
