@echo off
REM Build verification script for FL Studio Hello World Plugin
REM This script helps verify that your build environment is set up correctly

setlocal enabledelayedexpansion

echo ==============================================
echo FL Studio Hello World Plugin - Build Test
echo ==============================================
echo.

REM Check for CMake
echo Checking for CMake...
cmake --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] CMake found
    cmake --version | findstr /C:"cmake version"
) else (
    echo [ERROR] CMake not found
    echo Please install CMake 3.15 or higher from https://cmake.org/
    pause
    exit /b 1
)

REM Check for Visual Studio or other compiler
echo.
echo Checking for Visual Studio...
where cl >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Visual Studio compiler found
) else (
    echo [WARNING] MSVC compiler not in PATH
    echo You may need to run this from a Visual Studio Developer Command Prompt
    echo Or install Visual Studio Build Tools
)

REM Check for Git
echo.
echo Checking for Git...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Git found
    git --version
) else (
    echo [WARNING] Git not found
    echo CMake will need internet access to download JUCE
)

echo.
echo ==============================================
echo Environment Check Complete
echo ==============================================
echo.

REM Check if we're in the right directory
if not exist "CMakeLists.txt" (
    echo [NOTE] CMakeLists.txt not found in current directory
    echo Make sure you're in the examples\HelloWorldPlugin directory
    echo.
    echo Run this script from: examples\HelloWorldPlugin\
    pause
    exit /b 0
)

REM Offer to run build
echo All required tools appear to be installed!
echo.
set /p BUILD_NOW="Would you like to try building the plugin now? (Y/N): "

if /i "%BUILD_NOW%"=="Y" (
    echo.
    echo Creating build directory...
    if not exist "build" mkdir build
    cd build
    
    echo.
    echo Running CMake configuration...
    echo Attempting to detect Visual Studio...
    
    REM Try Visual Studio 2022 first
    cmake .. -G "Visual Studio 17 2022" -A x64 >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Configured with Visual Studio 2022
        goto BUILD
    )
    
    REM Try Visual Studio 2019
    cmake .. -G "Visual Studio 16 2019" -A x64 >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Configured with Visual Studio 2019
        goto BUILD
    )
    
    REM Try default generator
    cmake ..
    if %errorlevel% neq 0 (
        echo [ERROR] CMake configuration failed
        echo Please check the error messages above
        pause
        exit /b 1
    )
    
    :BUILD
    echo.
    echo Building plugin...
    echo This may take a few minutes on first run (downloading JUCE)...
    cmake --build . --config Release
    if %errorlevel% neq 0 (
        echo [ERROR] Build failed
        pause
        exit /b 1
    )
    
    echo.
    echo ==============================================
    echo Build Successful!
    echo ==============================================
    echo.
    echo The plugin DLL should be in:
    echo   build\Release\HelloWorld.dll
    echo.
    echo To install in FL Studio:
    echo 1. Copy HelloWorld.dll to:
    echo    ^<FL Studio^>\Plugins\Fruity\Generators\HelloWorld\
    echo 2. Restart FL Studio
    echo 3. Find the plugin under Generators -^> HelloWorld
    echo.
) else (
    echo.
    echo Skipping build. When ready, run:
    echo   mkdir build
    echo   cd build
    echo   cmake .. -G "Visual Studio 16 2019" -A x64
    echo   cmake --build . --config Release
    echo.
)

echo For more information, see:
echo   - QUICKSTART.md for detailed instructions
echo   - README.md for plugin documentation
echo   - ARCHITECTURE.md for technical details
echo.
pause
