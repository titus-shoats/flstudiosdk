# FL Studio Plugin SDK

This repository contains documentation and source files for developing FL Studio plugins.

## Repository Structure

- **HTML Documentation** - Root directory contains HTML documentation for the FL Studio Plugin SDK
  - Open `titlescreen.html` or `menu.html` to browse the documentation
  
- **SDK/Delphi/** - Delphi source files for plugin development
  - `FP_DelphiPlug.pas` - Delphi helper class with utility functions
  - `FP_PlugClass.pas` - Core plugin and host class definitions
  - `README.md` - Delphi SDK documentation and usage guide

- **examples/** - HTML documentation for example plugins
  - FruityGain (effect plugin)
  - Sine (simple generator)
  - Osc3 (polyphonic generator)

## Getting Started

### For Plugin Development

1. **Delphi Developers**: See [SDK/Delphi/README.md](SDK/Delphi/README.md) for Delphi-specific documentation and usage examples

2. **Documentation**: Open the HTML documentation by viewing `titlescreen.html` in a web browser for comprehensive SDK documentation

### Plugin Types

FL Studio supports several types of plugins:
- **Effect Plugins** - Process audio data
- **Generator Plugins** - Create sounds (appear as channels in FL Studio)
- **Visual Plugins** - Provide visualization without audio processing

## Documentation

The SDK includes detailed HTML documentation covering:
- General principles and guidelines
- Getting started guides
- API reference (constants, types, functions)
- Class references (TFruityPlug, TFruityPlugHost, TDelphiFruityPlug)
- Example implementations

## License

FL Studio SDK - refer to Image-Line's SDK license terms.

## Contact

For updates and support, visit the Image-Line Developer's Arena.
