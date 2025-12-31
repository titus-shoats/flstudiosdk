# FL Studio SDK

This repository contains the FL Studio SDK documentation and examples for creating native FL Studio plugins.

![Hello World Plugin Preview](https://github.com/user-attachments/assets/7fcafc23-0f34-4300-b4bd-7b934afeb0d3)

## Contents

- **HTML Documentation**: Complete API reference for the FL Studio plugin SDK
- **SDK Headers**: C++ header files for plugin development (`sdk/include/`)
- **Examples**: Sample plugins demonstrating various features

## Quick Start

To create a native FL Studio plugin:

1. Include the SDK headers from `sdk/include/`
2. Implement the `TFruityPlug` interface
3. Export the `CreatePlugInstance` function
4. Build as a DLL
5. Install in FL Studio's plugin directory

## Examples

### Hello World Plugin with JUCE

Located in `examples/HelloWorldPlugin/`, this demonstrates:
- Creating a native FL Studio generator plugin
- Using JUCE for the GUI
- Displaying "Hello World" text in a plugin window
- Basic plugin structure and integration

See [examples/HelloWorldPlugin/README.md](examples/HelloWorldPlugin/README.md) for detailed build and usage instructions.

## SDK Structure

### Header Files (`sdk/include/`)

- **fp_plugclass.h**: Main plugin class (`TFruityPlug`) and plugin info structure
- **fp_plughost.h**: Host interface for communicating with FL Studio

### Documentation (HTML files in root)

The HTML files provide comprehensive documentation:

- **fruityplug.html**: TFruityPlug class reference
- **fruityplughost.html**: TFruityPlugHost class reference
- **fruitypluginfo.html**: TFruityPlugInfo structure
- **constants.html**: All SDK constants and flags
- **types.html**: Type definitions
- **gettingstarted/**: Tutorial on creating plugins

## Plugin Types

FL Studio supports several types of plugins:

- **Generators**: Create sound (synthesizers, samplers)
- **Effects**: Process audio (reverb, delay, EQ)
- **Visual**: Display-only plugins (no audio processing)

Set the appropriate flags in `TFruityPlugInfo.Flags` to specify your plugin type.

## Building Plugins

### Requirements

- C++ compiler (Visual Studio, GCC, Clang)
- CMake (for the examples)
- Windows SDK (for Windows-specific functions)

### Example Build Process

```bash
cd examples/HelloWorldPlugin
mkdir build && cd build
cmake .. -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
```

### Installation

1. Create a folder: `<FL Studio>/Plugins/Fruity/<Type>/<PluginName>/`
   - `<Type>` is "Effects" or "Generators"
   - `<PluginName>` matches your DLL name (without .dll)

2. Copy your DLL into this folder

3. Restart FL Studio

## Creating Your First Plugin

### Minimal Plugin Structure

```cpp
#include "fp_plugclass.h"
#include "fp_plughost.h"

TFruityPlugHost *PlugHost = nullptr;

class MyPlugin : public TFruityPlug {
    static TFruityPlugInfo s_Info;
public:
    MyPlugin(int Tag) {
        HostTag = Tag;
        Info = &s_Info;
    }
    // Override virtual methods as needed
};

TFruityPlugInfo MyPlugin::s_Info = {
    CurrentSDKVersion,
    (char*)"MyPlugin",
    (char*)"MyPlug",
    FPF_Generator,  // or 0 for effect
    0,  // NumParams
    0,  // DefPoly
    0,  // NumOutCtrls
    {0}
};

extern "C" __declspec(dllexport) TFruityPlug* _stdcall 
CreatePlugInstance(TFruityPlugHost *Host, int Tag) {
    PlugHost = Host;
    return new MyPlugin(Tag);
}
```

### Key Methods to Implement

- **Dispatcher()**: Handle messages from FL Studio
- **Render()** or **Voice_Render()**: Generate/process audio
- **ProcessParam()**: Handle parameter changes
- **SaveRestoreState()**: Save/load plugin state
- **GetName()**: Provide text for parameters, presets, etc.

## Using JUCE for GUI

The Hello World example demonstrates integrating JUCE for the GUI:

1. Include JUCE headers
2. Create a `juce::Component` for your UI
3. Initialize JUCE in the plugin constructor
4. Embed the JUCE window in FL Studio's window

See the example for complete implementation details.

## Resources

- **JUCE Framework**: https://github.com/juce-framework/JUCE
- **FL Studio**: https://www.image-line.com/fl-studio/

## Plugin Development Tips

1. **Thread Safety**: FL Studio calls plugins from multiple threads
   - Use locks when accessing shared data
   - GUI operations should be on the main thread

2. **Performance**: Audio processing happens in real-time
   - Keep `Render()` and `Voice_Render()` efficient
   - Avoid allocations in audio callback

3. **State Management**: Save all necessary state in `SaveRestoreState()`
   - Users expect presets to work
   - Projects should load correctly

4. **Testing**: Test your plugin thoroughly
   - Try different sample rates and buffer sizes
   - Test save/load functionality
   - Check parameter automation

## API Documentation

For detailed API documentation, open the HTML files in a web browser:

- Start with `gettingstarted/principles.html`
- Browse the individual class documentation
- Check `constants.html` for all available flags and options

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This SDK documentation and examples are provided for educational purposes. Please check with Image-Line for official licensing information regarding FL Studio plugin development.

JUCE has separate licensing terms (GPL or commercial license required for commercial use).

## Support

For questions about the SDK:
- Check the HTML documentation
- Review the example code
- Visit the FL Studio forums

For JUCE-related questions:
- Visit the JUCE forum: https://forum.juce.com/
- Check JUCE documentation: https://docs.juce.com/

## Version

SDK Version: 1.0
Last Updated: 2025
