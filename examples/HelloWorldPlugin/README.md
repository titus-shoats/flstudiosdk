# FL Studio Hello World Plugin with JUCE

This is a simple "Hello World" native FL Studio plugin that demonstrates how to use the FL Studio SDK with JUCE for the GUI.

## Overview

This plugin combines:
- **FL Studio SDK** for the native plugin interface
- **JUCE Framework** for the GUI rendering

The plugin displays a window with "Hello World" text centered in the middle, rendered using JUCE's graphics capabilities.

## Features

- Native FL Studio plugin (not VST/AU)
- JUCE-based GUI with gradient background
- Clean "Hello World" display centered in the window
- Minimal, educational implementation

## Prerequisites

To build this plugin, you need:

1. **CMake** (3.15 or higher)
2. **C++ Compiler** (Visual Studio 2019+ recommended on Windows)
3. **JUCE Framework** (automatically downloaded by CMake)
4. **FL Studio** (to test the plugin)

## Building the Plugin

### Windows (Visual Studio)

```bash
cd examples/HelloWorldPlugin
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
```

### Windows (MinGW)

```bash
cd examples/HelloWorldPlugin
mkdir build
cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
```

### Linux (Cross-compile for Windows)

```bash
cd examples/HelloWorldPlugin
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=/path/to/mingw-toolchain.cmake
make
```

## Installation

1. After building, you'll find `HelloWorld.dll` in the `build/Release` or `build` directory

2. Create a folder in FL Studio's plugin directory:
   ```
   <FL Studio Installation>/Plugins/Fruity/Generators/HelloWorld/
   ```

3. Copy `HelloWorld.dll` to that folder

4. Start FL Studio and look for "HelloWorld" in the generator plugins menu

## Project Structure

```
examples/HelloWorldPlugin/
├── CMakeLists.txt              # Build configuration
├── README.md                   # This file
└── src/
    ├── HelloWorldPlugin.h      # Main plugin class header
    ├── HelloWorldPlugin.cpp    # Main plugin implementation
    ├── HelloWorldEditor.h      # JUCE GUI component header
    └── HelloWorldEditor.cpp    # JUCE GUI implementation
```

## How It Works

### FL Studio SDK Integration

The plugin implements the FL Studio native plugin interface through the `TFruityPlug` class:

1. **CreatePlugInstance**: Entry point called by FL Studio to create the plugin
2. **TFruityPlug**: Base class providing the plugin interface
3. **Dispatcher**: Handles messages from FL Studio (like showing/hiding the editor)
4. **TFruityPlugInfo**: Describes the plugin (name, flags, parameters, etc.)

### JUCE GUI Integration

The GUI is implemented using JUCE:

1. **HelloWorldEditor**: A JUCE Component that draws the "Hello World" text
2. **paint()**: Renders the gradient background and text
3. **Embedding**: The JUCE component is embedded in a window that FL Studio can display

### Key Files

- `fp_plugclass.h`: FL Studio SDK plugin class definitions
- `fp_plughost.h`: FL Studio host interface definitions
- `HelloWorldPlugin.cpp`: Main plugin logic and FL Studio integration
- `HelloWorldEditor.cpp`: JUCE GUI rendering code

## Customization

To customize this plugin:

1. **Change the text**: Edit `HelloWorldEditor.cpp`, modify the `g.drawText()` call
2. **Change colors**: Modify the gradient colors in `paint()`
3. **Add parameters**: Add entries to `NumParams` in the plugin info and implement parameter handling
4. **Add controls**: Add JUCE components in `HelloWorldEditor` constructor

## Limitations

This is a minimal educational example:

- No audio processing (it's a generator but doesn't generate audio)
- No parameters or controls
- No preset management
- No MIDI handling

For a production plugin, you would add:
- Audio rendering in `Voice_Render()` or `Render()`
- Parameter system with `ProcessParam()`
- State save/load in `SaveRestoreState()`
- MIDI input handling in `MIDIIn()`

## References

- FL Studio SDK: https://github.com/titus-shoats/flstudiosdk/
- JUCE Framework: https://github.com/juce-framework/JUCE
- FL Studio Plugin Documentation: See the HTML docs in the SDK root

## License

This example is provided as-is for educational purposes. JUCE has its own licensing terms (GPL or commercial). Please review JUCE's license before using this code in commercial products.

## Troubleshooting

### Plugin doesn't show up in FL Studio

- Make sure the DLL is in the correct folder structure
- Check that the plugin folder has the same name as the DLL (without .dll)
- Verify FL Studio is the correct architecture (x64 DLL for x64 FL Studio)

### Build errors

- Ensure CMake can download JUCE (internet connection required)
- Check that you have a C++17 compatible compiler
- On Windows, use Visual Studio 2019 or later

### JUCE window doesn't display

- Check that JUCE is properly initialized (`initialiseJuce_GUI()`)
- Verify the window handle is valid
- Check FL Studio's window parent handle is being passed correctly

## Contributing

Feel free to submit issues or pull requests to improve this example!
