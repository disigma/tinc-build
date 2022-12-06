cmake_minimum_required(VERSION 3.0)

include(../../../cmake/Me.cmake)

me_project(libressl-3.6.1 3RD META)
me_project(crypto.libressl-3.6.1 3RD ALIAS)

me_cmake(
    FLAGS
    -DLIBRESSL_APPS=OFF
    -DLIBRESSL_TESTS=OFF
    -DENABLE_EXTRATESTS=OFF
    -DBUILD_SHARED_LIBS=OFF
)
me_make()
