# Copyright 2019 Collabora, Ltd.
# SPDX-License-Identifier: BSL-1.0

### Generated file! Edit the templates in src/templates then re-run ./make-cmake.py

set(SOURCES filter_createiso.cpp)

set(HEADERS filter_createiso.h)

add_library(filter_createiso MODULE ${SOURCES} ${HEADERS})

target_include_directories(filter_createiso PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(filter_createiso PUBLIC common)

set_property(TARGET filter_createiso PROPERTY FOLDER Plugins)

set_property(TARGET filter_createiso PROPERTY RUNTIME_OUTPUT_DIRECTORY
                                              ${MESHLAB_PLUGIN_OUTPUT_DIR})

set_property(TARGET filter_createiso PROPERTY LIBRARY_OUTPUT_DIRECTORY
                                              ${MESHLAB_PLUGIN_OUTPUT_DIR})

install(TARGETS filter_createiso DESTINATION ${MESHLAB_PLUGIN_INSTALL_DIR}
                COMPONENT Plugins)
