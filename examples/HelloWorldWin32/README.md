# FL Studio Hello World Plugin - Win32 Implementation

A simple "Hello World" FL Studio native plugin using **Win32 API only** (no JUCE).

![Hello World Plugin](../../../preview.png)

## Overview

This example demonstrates how to create a working FL Studio native plugin with a graphical user interface using the Win32 API. Unlike the JUCE version, this implementation integrates seamlessly with FL Studio's message loop and doesn't cause freezing issues.

## Features

- ✅ **Pure Win32 GUI** - No external frameworks required
- ✅ **Flicker-free rendering** - Double buffering with memory DC
- ✅ **Proper window hierarchy** - Uses `WS_CLIPCHILDREN` to prevent parent overdraw
- ✅ **Gradient background** - Smooth blue gradient effect
- ✅ **Custom text rendering** - Centered "Hello World" with subtitle
- ✅ **Best practices** - Follows Win32 best practices for plugin GUIs

## Win32 Best Practices Implemented

### 1. Window Class Configuration
```cpp
wc.style = CS_OWNDC; // No CS_HREDRAW/CS_VREDRAW
```
Prevents automatic full window redraws on resize, reducing unnecessary painting.

### 2. Parent-Child Window Management
```cpp
WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN
```
- `WS_CHILD` - Window is a child of FL Studio's window
- `WS_CLIPCHILDREN` - Prevents parent from painting over this window
- Essential for eliminating visual artifacts

### 3. Double Buffering
```cpp
HDC memDC = CreateCompatibleDC(hdc);
HBITMAP memBitmap = CreateCompatibleBitmap(hdc, width, height);
// Draw to memDC
BitBlt(hdc, 0, 0, width, height, memDC, 0, 0, SRCCOPY);
```
All drawing happens to an off-screen buffer, then copied to screen in one operation. This eliminates flicker completely.

### 4. Background Erase Handling
```cpp
case WM_ERASEBKGND:
    return 1; // Skip default erase
```
We handle background in `WM_PAINT`, so we skip the default erase to prevent double-painting.

## Building

### Windows (Visual Studio)

```batch
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
```

### Output

The built DLL will be in:
```
build/Release/HelloWorldWin32_x64.dll
```

## Installation

1. Build the plugin (see above)
2. Copy the DLL to FL Studio's plugin directory:
   ```
   <FL Studio>/Plugins/Fruity/Generators/HelloWorldWin32/HelloWorldWin32_x64.dll
   ```
3. Restart FL Studio
4. The plugin will appear in the generators list as "HelloWorldWin32"

## Code Structure

### HelloWorldWin32Plugin.h
- Plugin class declaration
- TFruityPlug interface implementation
- Window procedure declaration

### HelloWorldWin32Plugin.cpp
- Plugin implementation
- Window creation and management
- Custom painting with gradient background
- Text rendering
- Export function for FL Studio

## How It Works

### 1. Plugin Registration
FL Studio calls `CreatePlugInstance()` which creates a new plugin instance.

### 2. Editor Show/Hide
When FL Studio wants to show the plugin UI:
- `Dispatcher(FPD_ShowEditor, ...)` is called
- Plugin creates a Win32 window as a child of FL Studio's window
- Window uses double buffering for flicker-free rendering

### 3. Rendering
The `OnPaint()` method:
1. Creates gradient background by drawing horizontal lines
2. Renders "Hello World" text centered in the window
3. Adds subtitle text below
4. All rendering happens to memory DC first (double buffering)

### 4. Message Handling
- Win32 handles all window messages automatically
- No manual message loop needed (unlike JUCE)
- Integrates perfectly with FL Studio's threading model

## Extending This Plugin

To add features:

1. **Parameters**: Add parameter handling in `Dispatcher(FPD_ProcessParam, ...)`
2. **Audio Processing**: Override `Gen()` or `Render()` methods
3. **State Management**: Implement `SaveRestoreState()`
4. **Custom Controls**: Add buttons, sliders using Win32 controls
5. **Mouse Input**: Handle `WM_LBUTTONDOWN`, `WM_MOUSEMOVE`, etc.

## Advantages Over JUCE

| Feature | Win32 | JUCE |
|---------|-------|------|
| Message Loop | FL Studio handles it ✅ | Requires bridge ❌ |
| Binary Size | Small (~50KB) | Large (~5MB+) |
| Dependencies | None | JUCE library |
| Complexity | Low | High |
| FL Studio Integration | Native ✅ | Problematic ❌ |
| Learning Curve | Moderate | Steep |

## License

This example is provided as-is for educational purposes.

## See Also

- [FL Studio SDK Documentation](../../ARCHITECTURE.md)
- [Win32 API Reference](https://docs.microsoft.com/en-us/windows/win32/)
- [GDI Documentation](https://docs.microsoft.com/en-us/windows/win32/gdi/windows-gdi)
