#!/bin/bash
# Build verification script for FL Studio Hello World Plugin
# This script helps verify that your build environment is set up correctly

set -e  # Exit on error

echo "=============================================="
echo "FL Studio Hello World Plugin - Build Test"
echo "=============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for CMake
echo -n "Checking for CMake... "
if command -v cmake &> /dev/null; then
    CMAKE_VERSION=$(cmake --version | head -n1)
    echo -e "${GREEN}✓${NC} Found: $CMAKE_VERSION"
else
    echo -e "${RED}✗${NC} Not found"
    echo "Please install CMake 3.15 or higher"
    exit 1
fi

# Check CMake version
CMAKE_VER=$(cmake --version | grep -oP '(?<=cmake version )[0-9]+\.[0-9]+' | head -n1)
CMAKE_MAJOR=$(echo $CMAKE_VER | cut -d. -f1)
CMAKE_MINOR=$(echo $CMAKE_VER | cut -d. -f2)
if [ "$CMAKE_MAJOR" -lt 3 ] || ([ "$CMAKE_MAJOR" -eq 3 ] && [ "$CMAKE_MINOR" -lt 15 ]); then
    echo -e "${YELLOW}⚠${NC} CMake version is $CMAKE_VER, but 3.15+ is recommended"
fi

# Check for C++ compiler
echo -n "Checking for C++ compiler... "
if command -v g++ &> /dev/null; then
    GCC_VERSION=$(g++ --version | head -n1)
    echo -e "${GREEN}✓${NC} Found: $GCC_VERSION"
elif command -v clang++ &> /dev/null; then
    CLANG_VERSION=$(clang++ --version | head -n1)
    echo -e "${GREEN}✓${NC} Found: $CLANG_VERSION"
elif command -v cl &> /dev/null; then
    echo -e "${GREEN}✓${NC} Found: MSVC"
else
    echo -e "${RED}✗${NC} Not found"
    echo "Please install a C++ compiler (GCC, Clang, or MSVC)"
    exit 1
fi

# Check for Git
echo -n "Checking for Git... "
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓${NC} Found: $GIT_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Not found (required for JUCE download)"
    echo "CMake will need internet access to download JUCE"
fi

# Check for Make or Ninja
echo -n "Checking for build tool... "
if command -v make &> /dev/null; then
    echo -e "${GREEN}✓${NC} Found: GNU Make"
elif command -v ninja &> /dev/null; then
    echo -e "${GREEN}✓${NC} Found: Ninja"
elif command -v msbuild &> /dev/null; then
    echo -e "${GREEN}✓${NC} Found: MSBuild"
else
    echo -e "${YELLOW}⚠${NC} No build tool found"
    echo "You may need to install build tools for your platform"
fi

echo ""
echo "=============================================="
echo "Environment Check Complete"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${YELLOW}Note:${NC} CMakeLists.txt not found in current directory"
    echo "Make sure you're in the examples/HelloWorldPlugin directory"
    echo ""
    echo "Run this script from: examples/HelloWorldPlugin/"
    exit 0
fi

# Offer to run build
echo "All required tools are installed!"
echo ""
read -p "Would you like to try building the plugin now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Creating build directory..."
    mkdir -p build
    cd build
    
    echo ""
    echo "Running CMake configuration..."
    cmake .. || { echo -e "${RED}CMake configuration failed${NC}"; exit 1; }
    
    echo ""
    echo "Building plugin..."
    cmake --build . --config Release || { echo -e "${RED}Build failed${NC}"; exit 1; }
    
    echo ""
    echo -e "${GREEN}=============================================="
    echo "Build Successful!"
    echo "==============================================${NC}"
    echo ""
    echo "The plugin DLL should be in:"
    echo "  build/Release/HelloWorld.dll (Windows)"
    echo "  build/HelloWorld.dll (Linux/Mac)"
    echo ""
    echo "To install in FL Studio:"
    echo "1. Copy HelloWorld.dll to:"
    echo "   <FL Studio>/Plugins/Fruity/Generators/HelloWorld/"
    echo "2. Restart FL Studio"
    echo "3. Find the plugin under Generators → HelloWorld"
    echo ""
else
    echo ""
    echo "Skipping build. When ready, run:"
    echo "  mkdir build && cd build"
    echo "  cmake .."
    echo "  cmake --build . --config Release"
    echo ""
fi

echo "For more information, see:"
echo "  - QUICKSTART.md for detailed instructions"
echo "  - README.md for plugin documentation"
echo "  - ARCHITECTURE.md for technical details"
echo ""
