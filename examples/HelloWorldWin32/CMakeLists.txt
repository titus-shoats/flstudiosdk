cmake_minimum_required(VERSION 3.15)
project(HelloWorldWin32FLPlugin VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Plugin source files
set(PLUGIN_SOURCES
    src/HelloWorldWin32Plugin.cpp
    src/HelloWorldWin32Plugin.h
)

# Create the plugin library
add_library(HelloWorldWin32_x64 SHARED ${PLUGIN_SOURCES})

# Set output name
set_target_properties(HelloWorldWin32_x64 PROPERTIES
    OUTPUT_NAME "HelloWorldWin32_x64"
    PREFIX ""
    SUFFIX ".dll"
)

# Include directories
target_include_directories(HelloWorldWin32_x64 PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../sdk/include
)

# Link Windows libraries
target_link_libraries(HelloWorldWin32_x64 PRIVATE
    gdi32
    user32
    ole32
)

# Compiler definitions for Windows
if(MSVC)
    target_compile_definitions(HelloWorldWin32_x64 PRIVATE
        _WINDOWS
        _USRDLL
        WIN32
        _WIN64
    )
    
    # Set warning level
    target_compile_options(HelloWorldWin32_x64 PRIVATE /W4)
endif()

# Install target
install(TARGETS HelloWorldWin32_x64
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
