cmake_minimum_required(VERSION 3.15)

project(HelloWorldFLPlugin VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Option to use system JUCE or download it
option(USE_SYSTEM_JUCE "Use system-installed JUCE" OFF)

if(NOT USE_SYSTEM_JUCE)
    # Download JUCE
    include(FetchContent)
    FetchContent_Declare(
        JUCE
        GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
        GIT_TAG 7.0.9
        GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(JUCE)
endif()

# Add FL Studio SDK include directory
include_directories(${CMAKE_SOURCE_DIR}/../../sdk/include)

# Create the plugin as a shared library (DLL)
add_library(HelloWorldFLPlugin SHARED
    src/HelloWorldPlugin.cpp
    src/HelloWorldEditor.cpp
)

# Link with JUCE modules
target_link_libraries(HelloWorldFLPlugin
    PRIVATE
        juce::juce_core
        juce::juce_gui_basics
        juce::juce_gui_extra
)

# Set output name and properties
set_target_properties(HelloWorldFLPlugin PROPERTIES
    OUTPUT_NAME "HelloWorld"
    PREFIX ""
    SUFFIX ".dll"
)

# Windows-specific settings
if(WIN32)
    target_compile_definitions(HelloWorldFLPlugin PRIVATE
        _WINDOWS
        NOMINMAX
    )
endif()

# Export symbols for FL Studio
if(MSVC)
    set_target_properties(HelloWorldFLPlugin PROPERTIES
        LINK_FLAGS "/EXPORT:CreatePlugInstance"
    )
else()
    target_compile_definitions(HelloWorldFLPlugin PRIVATE
        __declspec(dllexport)=__attribute__((visibility("default")))
    )
endif()
