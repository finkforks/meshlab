# Copyright 2019 Collabora, Ltd.
# SPDX-License-Identifier: BSL-1.0

### Generated file! Edit the templates in src/templates then re-run ./make-cmake.py

set(SOURCES io_bre.cpp)

set(HEADERS io_bre.h)

add_library(io_bre MODULE ${SOURCES} ${HEADERS})

target_include_directories(io_bre PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(io_bre PUBLIC common)

set_property(TARGET io_bre PROPERTY FOLDER Plugins)

set_property(TARGET io_bre PROPERTY RUNTIME_OUTPUT_DIRECTORY
                                    ${MESHLAB_PLUGIN_OUTPUT_DIR})

set_property(TARGET io_bre PROPERTY LIBRARY_OUTPUT_DIRECTORY
                                    ${MESHLAB_PLUGIN_OUTPUT_DIR})

install(TARGETS io_bre DESTINATION ${MESHLAB_PLUGIN_INSTALL_DIR} COMPONENT
                Plugins)
