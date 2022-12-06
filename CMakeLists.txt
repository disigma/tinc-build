cmake_minimum_required(VERSION 3.0)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  project(mix)
endif()

include(cmake/MeRoot.cmake)
include(cmake/Me.cmake)

me_import(tinc-1.0.36)

me_import(${ME_EXTRA_PROJECTS})

if(CMAKE_SCRIPT_MODE_FILE)
  include(MeMakefile)
  me_makefile_make(strip-all)
  return()
endif()

include(cmake/MeStripAll.cmake)
