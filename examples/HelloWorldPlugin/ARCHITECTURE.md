# FL Studio Hello World Plugin - Architecture

## Overview

This document explains how the Hello World plugin integrates the FL Studio SDK with JUCE.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      FL Studio Host                          │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Plugin Manager                                     │    │
│  │  - Loads HelloWorld.dll                            │    │
│  │  - Calls CreatePlugInstance()                      │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          │ TFruityPlugHost interface        │
│                          ▼                                   │
└──────────────────────────┼───────────────────────────────────┘
                           │
                           │
┌──────────────────────────┼───────────────────────────────────┐
│                          │         HelloWorld.dll            │
│  ┌───────────────────────▼──────────────────────────┐       │
│  │  CreatePlugInstance()                            │       │
│  │  - Exported function                             │       │
│  │  - Entry point for FL Studio                     │       │
│  └──────────────────────┬───────────────────────────┘       │
│                         │                                    │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────┐       │
│  │  HelloWorldPlugin : TFruityPlug                  │       │
│  │                                                   │       │
│  │  - Implements FL Studio plugin interface         │       │
│  │  - Handles Dispatcher messages                   │       │
│  │  - Manages plugin lifecycle                      │       │
│  │                                                   │       │
│  │  Methods:                                         │       │
│  │    • Dispatcher() - handle FL Studio messages    │       │
│  │    • ShowEditor() - create/show GUI              │       │
│  │    • HideEditor() - destroy/hide GUI             │       │
│  │    • SaveRestoreState() - persistence            │       │
│  └──────────────────────┬───────────────────────────┘       │
│                         │                                    │
│                         │ owns                               │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────┐       │
│  │  HelloWorldEditor : juce::Component              │       │
│  │                                                   │       │
│  │  - JUCE GUI component                            │       │
│  │  - Renders "Hello World" text                    │       │
│  │  - Handles paint() events                        │       │
│  │                                                   │       │
│  │  Methods:                                         │       │
│  │    • paint() - draw gradient + text              │       │
│  │    • resized() - layout management               │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │  JUCE Framework                                   │       │
│  │  - juce::Component                               │       │
│  │  - juce::Graphics                                │       │
│  │  - juce::DocumentWindow                          │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

### FL Studio SDK Layer

1. **fp_plugclass.h**
   - Defines `TFruityPlug` base class
   - Defines `TFruityPlugInfo` structure
   - Plugin flags and constants

2. **fp_plughost.h**
   - Defines `TFruityPlugHost` interface
   - Communication channel to FL Studio

3. **CreatePlugInstance()**
   - DLL export function
   - FL Studio calls this to create plugin instances
   - Receives `TFruityPlugHost*` and `Tag`
   - Returns `TFruityPlug*`

### Plugin Implementation Layer

4. **HelloWorldPlugin**
   - Inherits from `TFruityPlug`
   - Implements FL Studio plugin interface
   - Creates and manages JUCE GUI
   - Handles lifecycle events

### GUI Layer

5. **HelloWorldEditor**
   - JUCE Component
   - Renders the visual interface
   - Independent of FL Studio specifics
   - Reusable GUI code

## Data Flow

### Plugin Loading

```
FL Studio starts
    → Scans plugin directory
    → Finds HelloWorld.dll
    → LoadLibrary(HelloWorld.dll)
    → GetProcAddress("CreatePlugInstance")
    → Calls CreatePlugInstance(host, tag)
    → Returns plugin instance
    → FL Studio stores plugin instance
```

### Showing Editor

```
User clicks "Show Editor"
    → FL Studio calls Dispatcher(FPD_ShowEditor, hwnd, 1)
    → Plugin creates HelloWorldEditor
    → Plugin creates window/embeds in parent
    → JUCE component renders to window
    → Window becomes visible
```

### Rendering

```
JUCE requests paint
    → HelloWorldEditor::paint() called
    → Draws gradient background
    → Draws "Hello World" text (48pt, bold, white)
    → Draws subtitle (16pt, grey)
    → Window updated on screen
```

## Key Integration Points

### FL Studio → Plugin

- **Dispatcher messages**: FL Studio sends commands
- **Parameter changes**: FL Studio notifies of automation
- **Audio callbacks**: FL Studio requests audio processing
- **State management**: FL Studio requests save/load

### Plugin → FL Studio

- **PlugHost interface**: Plugin calls host functions
- **MIDI output**: Plugin can send MIDI
- **Parameter updates**: Plugin can update parameters
- **UI hints**: Plugin can show status messages

### Plugin → JUCE

- **Component hierarchy**: Plugin owns JUCE components
- **Window management**: Plugin creates/destroys windows
- **Event handling**: JUCE handles mouse/keyboard
- **Rendering**: JUCE handles all drawing

## Thread Safety

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│   GUI Thread    │     │   Mixer Thread   │     │ MIDI Thread │
│                 │     │                  │     │             │
│ • Dispatcher()  │     │ • Render()       │     │ • MIDIIn()  │
│ • Idle()        │     │ • Voice_Render() │     │             │
│ • paint()       │     │                  │     │             │
└─────────────────┘     └──────────────────┘     └─────────────┘
         │                       │                      │
         └───────────────────────┴──────────────────────┘
                                 │
                          Uses Lock/Unlock
                          for shared data
```

## Build Process

```
CMake Configuration
    → Downloads JUCE from GitHub
    → Configures JUCE modules
    → Sets up include paths
    → Configures compiler flags

Compilation
    → Compiles HelloWorldEditor.cpp
    → Compiles HelloWorldPlugin.cpp
    → Links with JUCE libraries
    → Links with Windows libraries

Linking
    → Creates HelloWorld.dll
    → Exports CreatePlugInstance
    → Embeds JUCE resources
    → Creates Windows DLL
```

## Installation

```
HelloWorld.dll
    → Copy to: Plugins/Fruity/Generators/HelloWorld/HelloWorld.dll
    
FL Studio loads plugin:
    → Scans directory
    → Matches folder name with DLL name
    → Loads and validates
    → Adds to plugin menu
```

## Future Enhancements

To extend this plugin:

1. **Add audio generation**
   - Implement `Voice_Render()`
   - Generate waveforms
   - Process MIDI input

2. **Add parameters**
   - Increase `NumParams`
   - Implement `ProcessParam()`
   - Add knobs/sliders to GUI

3. **Add presets**
   - Implement `SaveRestoreState()`
   - Save parameters to stream
   - Load parameters from stream

4. **Add MIDI**
   - Implement `MIDIIn()`
   - Process note on/off
   - Control parameters via MIDI CC
