# Include this file in each subproject.
#
# It provides some functions to create projects.
#
# * Use me_project() to create a project.
# * Use me_autoconf() / me_configure() / me_make() to build a GNU autotools
#   project.
# * Use me_cmake() / me_make() to build an external cmake project.
# * Use me_meson() / me_make() to build an external meson project.
#
# The following cache variables will be set:
#
# * ME_BUILD_ROOT: The root build directory.

cmake_minimum_required(VERSION 3.0)

if(ME_CMAKE_INCLUDED)
  return()
endif()
set(ME_CMAKE_INCLUDED ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)

if(CMAKE_SCRIPT_MODE_FILE)
  include(MeMakefile)
endif()

include(MeDetectRoot)
me_detect_root(${CMAKE_CURRENT_SOURCE_DIR}/..)

include(MeAutoconf)
include(MeBuild)
include(MeCMake)
include(MeConfigure)
include(MeDetectTarget)
include(MeDetectVersion)
include(MeGenerateHeader)
include(MeGenerateVersion)
include(MeImport)
include(MeMake)
include(MeProject)

me_detect_version()
me_detect_target(ME)

set(ME_BUILD_ROOT ${CMAKE_BINARY_DIR} CACHE PATH ME_BUILD_ROOT)
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE BOOL CMAKE_BUILD_WITH_INSTALL_RPATH)
