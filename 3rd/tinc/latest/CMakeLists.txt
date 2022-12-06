cmake_minimum_required(VERSION 3.0)

include(../../../cmake/Me.cmake)

me_project(tinc-1.0.36 3RD DEPENDS zlib-1.2.11 crypto.libressl-3.6.1 lzo-2.10)
me_autoconf()
me_configure(FLAGS --with-zlib=${zlib-1.2.11-PREFIX} --with-lzo=${lzo-2.10-PREFIX} --with-openssl=${libressl-3.6.1-PREFIX} LIBS=-pthread)
me_make()
