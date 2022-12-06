# Recursively look for the parent directory to detect the project root
# directory.
#
# The following cache variables will be exported on success:
#
# * ME_ROOT_DIR: project root directory.
# * ME_CMAKE_DIR: cmake module directory.
function(me_detect_root search)
  if(ME_ROOT_DIR)
    return()
  endif()

  if(NOT IS_ABSOLUTE ${search})
    get_filename_component(search ${search} ABSOLUTE)
  endif()

  if(NOT IS_DIRECTORY ${search})
    return()
  elseif(EXISTS ${search}/cmake/MeRoot.cmake)
    include(${search}/cmake/MeRoot.cmake)
  endif()

  if(NOT ME_ROOT_DIR)
    get_filename_component(next ${search}/.. ABSOLUTE)
    if(next STREQUAL search)
      set(ME_STANDALONE ON CACHE BOOL ME_STANDALONE FORCE)
      include(MeRoot)
    else()
      me_detect_root(${next})
    endif()
  endif()
endfunction(me_detect_root)
