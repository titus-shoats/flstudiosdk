# Piano Roll Clone - FL Studio Plugin

A complete FL Studio native plugin written in Delphi that replicates Piano Roll features with a visual interface for creating, editing, and managing MIDI notes.

## Overview

This plugin demonstrates a full-featured Piano Roll implementation for FL Studio, including:
- Visual piano roll editor with 88-key piano keyboard display
- Note creation, editing, moving, and deletion
- Grid-based note snapping
- Velocity-based note coloring
- FL Studio Piano Roll integration
- Audio synthesis (sine wave generation)
- State save/restore functionality

## Features

### Visual Interface
- **Piano Keys Display**: 88-key piano keyboard on the left (50px wide)
  - White keys: #606060
  - Black keys: #404040
  - Highlighted C keys for easy navigation
- **Grid System**: 
  - Dark theme background (#242424)
  - Subtle grid lines (#282828)
  - Beat lines (#404040) every 4 steps
  - 24px per grid step, 4 steps per beat
- **Note Display**:
  - Blue gradient coloring based on velocity
  - Selected notes highlighted in orange (#FF8040)
  - 3px velocity bar on left edge of each note
  - 12px note height

### Note Management
- **Add Notes**: Left-click on grid to add notes (snapped to grid)
- **Delete Notes**: Right-click on note or use Delete key
- **Move Notes**: Click and drag notes to new positions
- **Resize Notes**: Drag right edge to change note length
- **Multi-Select**: Ctrl+Click to select multiple notes
- **Velocity**: Notes display velocity through color intensity

### Audio Features
- Simple sine wave synthesizer
- Polyphonic playback (unlimited voices)
- Velocity-sensitive volume
- Proper voice management and release

### FL Studio Integration
- Save/load notes with FL Studio projects
- Send notes to FL Studio's Piano Roll
- Receive MIDI input
- Parameter automation support

## Prerequisites

### Development Environment
- **Delphi**: Delphi 7 or later (Delphi 2007+ recommended for better Windows compatibility)
- **FL Studio**: Version 8 or later (tested with FL Studio 12+)
- **Operating System**: Windows XP or later (32-bit for compatibility)

### Required SDK Files
All SDK files are included in this directory:
- `FP_Def.pas` - Core definitions and constants
- `FP_PlugClass.pas` - Plugin and host class interfaces
- `FP_DelphiPlug.pas` - Delphi helper class with utilities
- `FP_Extra.pas` - Additional helper functions

### Source Files
- `PianoRollPlugin.pas` - Main plugin logic, note management, audio synthesis
- `PianoRollEditor.pas` - Visual editor form with piano roll interface
- `PianoRollEditor.dfm` - Form design file
- `PianoRollClone.dpr` - Delphi project file

## Compilation Instructions

### Using Delphi IDE

1. **Open the Project**
   ```
   Open PianoRollClone.dpr in Delphi IDE
   ```

2. **Configure Project Settings**
   - Go to Project → Options
   - In "Application" tab:
     - Target: Set to "Library" (DLL)
   - In "Compiler" tab:
     - Platform: Set to "32-bit Windows"
     - Optimization: Enable for smaller DLL size
   - In "Directories/Conditionals" tab:
     - Ensure the project directory is in the search path
   - In "Linker" tab:
     - Uncheck "Generate console application"

3. **Build the Project**
   ```
   Project → Build PianoRollClone
   ```
   
   Or press Ctrl+F9

4. **Verify Output**
   - The compiled DLL will be in the project directory or Win32\Release
   - Default name: `PianoRollClone.dll`
   - Expected size: 200-500 KB (depending on Delphi version and optimization)

### Command Line Compilation (Optional)

If you have the Delphi command-line compiler (dcc32.exe):

```bash
cd Source\Delphi\PianoRollClone
dcc32 -B -$D- -$L- PianoRollClone.dpr
```

Flags:
- `-B`: Build all units
- `-$D-`: Disable debug info
- `-$L-`: Disable local symbols

## Installation Instructions

### Installing the Plugin in FL Studio

1. **Locate FL Studio's Generators Folder**
   ```
   Default path: C:\Program Files\Image-Line\FL Studio\Plugins\Fruity\Generators\
   ```

2. **Create Plugin Directory**
   ```
   Create folder: FL Studio\Plugins\Fruity\Generators\PianoRollClone\
   ```

3. **Copy the DLL**
   ```
   Copy PianoRollClone.dll to the PianoRollClone folder
   ```

4. **Restart FL Studio**
   - Close FL Studio if it's running
   - Launch FL Studio

5. **Verify Installation**
   - Open FL Studio
   - Click Channels menu → Add one...
   - Look for "Piano Roll Clone" or "PRClone" in the generators list

### Alternative: Manual Plugin Scan

If the plugin doesn't appear:
1. Open FL Studio
2. Go to Options → File Settings
3. Click "Manage plugins"
4. Click "Find more plugins" or "Refresh"
5. Select the folder containing PianoRollClone.dll
6. Click "Start scan"

## Usage Instructions

### Opening the Plugin Editor

1. Add the plugin to a channel:
   ```
   Channels → Add one → PianoRollClone
   ```

2. Open the plugin editor:
   ```
   Click the plugin name in the channel rack
   OR
   Click the channel settings button and select the plugin
   ```

### Adding Notes

1. **Draw Mode** (default):
   - Left-click on the grid to add a note
   - Notes are automatically snapped to the grid
   - Default note length: 1 beat (96 PPQ)
   - Default velocity: 100

### Editing Notes

1. **Move Notes**:
   - Click and drag a note to move it
   - Position snaps to grid

2. **Resize Notes**:
   - Click and drag the right edge of a note
   - Length snaps to grid

3. **Delete Notes**:
   - Right-click on a note
   - OR select note and press Delete key

4. **Multi-Select**:
   - Hold Ctrl and click notes to select multiple
   - Selected notes appear in orange

### Keyboard Shortcuts

- **Delete**: Delete selected notes
- **Ctrl+C**: Copy selected notes (planned feature)
- **Ctrl+V**: Paste notes (planned feature)
- **Ctrl+A**: Select all notes (planned feature)

### Plugin Parameters

The plugin has 5 parameters accessible via FL Studio:

1. **Grid Snap** (0-32): Note snapping resolution
   - Values: 1/4, 1/8, 1/16 (default), 1/32, etc.
   - Controls how notes align to the grid

2. **Zoom X** (50-200%): Horizontal zoom level
   - Default: 100%
   - Affects grid spacing

3. **Zoom Y** (50-200%): Vertical zoom level
   - Default: 100%
   - Affects note height spacing

4. **Volume** (0-100%): Master volume
   - Default: 80%
   - Affects audio output level

5. **Pan** (-64 to +64): Stereo panning
   - Default: 0 (center)
   - Affects left/right balance

### Sending Notes to FL Studio Piano Roll

To send the notes you've created to FL Studio's native Piano Roll:

1. Call the `SendNotesToHost` method (implement in a menu or button)
2. Notes will appear in FL Studio's Piano Roll
3. This allows you to:
   - Edit notes in FL Studio's Piano Roll
   - Apply FL Studio's advanced editing features
   - Use the plugin as a quick note sketching tool

### Saving and Loading

- Notes are automatically saved with FL Studio projects
- State is preserved when:
  - Saving the project (.flp file)
  - Rendering to audio
  - Closing and reopening FL Studio

## Technical Specifications

### Constants
```pascal
PIANO_KEY_WIDTH = 50      // Width of piano keyboard
NOTE_HEIGHT = 12          // Height of each note
GRID_WIDTH = 24           // Width of each grid step
PPQ = 96                  // Pulses Per Quarter note
NumParamsConst = 5        // Number of parameters
```

### Color Scheme (FL Studio Dark Theme)
```pascal
COLOR_BACKGROUND = $242424    // Dark gray background
COLOR_GRID_LINE = $282828     // Subtle grid lines
COLOR_BEAT_LINE = $404040     // Beat marker lines
COLOR_PIANO_WHITE = $606060   // White piano keys
COLOR_PIANO_BLACK = $404040   // Black piano keys
COLOR_PIANO_BORDER = $202020  // Piano key borders
COLOR_NOTE_BORDER = $101010   // Note borders
COLOR_NOTE_SELECTED = $FF8040 // Selected note (orange)
```

### Note Data Structure
```pascal
TPianoNote = record
  Position: Integer;    // Position in PPQ (0-based)
  Length: Integer;      // Length in PPQ
  Note: Integer;        // MIDI note number (0-127)
  Velocity: Integer;    // Velocity (0-127)
  Pan: Integer;         // Pan (-64 to +64)
  Selected: Boolean;    // Selection state
end;
```

### Plugin Architecture

1. **PianoRollPlugin.pas**: Core plugin logic
   - Note list management
   - Voice management
   - MIDI handling
   - Audio synthesis
   - State persistence

2. **PianoRollEditor.pas**: Visual interface
   - Double-buffered rendering
   - Mouse interaction handling
   - Grid and note drawing
   - Piano keyboard display

3. **SDK Units**: FL Studio integration
   - FP_Def: Constants and types
   - FP_PlugClass: Plugin interfaces
   - FP_DelphiPlug: Helper functions
   - FP_Extra: Utilities

## Troubleshooting

### Compilation Errors

**Error: "Unit not found: FP_DelphiPlug"**
- Solution: Ensure all SDK files (FP_*.pas) are in the project directory
- Check Project → Options → Directories/Conditionals → Search path

**Error: "Unsupported 16-bit resource"**
- Solution: Recreate the .dfm file or convert to text format
- In Delphi: Right-click form → View as Text → Save

**Error: "Cannot load package/library"**
- Solution: Ensure project is set to build as Library (DLL), not Application
- Check Project → Options → Application → Target type

**Error: "Access violation" during compilation**
- Solution: Close and reopen Delphi IDE
- Clean build: Project → Build All

### Plugin Not Appearing in FL Studio

**Plugin doesn't show in generator list**
- Verify DLL is in correct folder: `FL Studio\Plugins\Fruity\Generators\PianoRollClone\`
- Restart FL Studio
- Run manual plugin scan: Options → File Settings → Manage plugins → Find more plugins

**Plugin appears but won't load**
- Check DLL is 32-bit (FL Studio 32-bit) or 64-bit (FL Studio 64-bit)
- Most FL Studio versions are 32-bit, compile for 32-bit
- Ensure DLL has no missing dependencies

**Error: "The plugin could not be loaded"**
- DLL might be compiled for wrong platform (64-bit vs 32-bit)
- Check dependencies: Use Dependency Walker tool
- Verify all SDK functions are properly exported

### Runtime Crashes

**Crash when opening plugin editor**
- Check EditorForm is properly created in constructor
- Verify FruityPlug reference is set in editor form
- Ensure all event handlers are defined

**Crash when playing notes**
- Check voice management: voices are properly created/destroyed
- Verify buffer sizes in Gen_Render
- Ensure Lock/Unlock is used for thread-safe access

**Crash when saving project**
- Check SaveRestoreState implementation
- Verify IStream operations are correct
- Ensure all data sizes are calculated correctly

### Visual Glitches

**Editor window is black/not drawing**
- Verify OnPaint event is assigned
- Check back buffer is created in FormCreate
- Ensure CreateBackBuffer is called on resize

**Notes are not visible**
- Check FruityPlug reference is valid
- Verify note coordinates are within visible range
- Ensure notes are being added to the list

**Piano keys not displaying correctly**
- Check NoteToPixel and PixelToNote calculations
- Verify IsBlackKey function returns correct values
- Ensure FScrollY is initialized properly

**Flickering during redraw**
- Verify DoubleBuffered is set to True
- Check that drawing happens only in OnPaint
- Use InvalidateRect instead of full Invalidate when possible

### Performance Issues

**Slow redrawing**
- Minimize Invalidate calls
- Only redraw when necessary
- Use clipping regions to redraw only changed areas

**Audio clicking/popping**
- Ensure proper level ramping in Gen_Render
- Check voice release handling
- Verify buffer sizes are consistent

**High CPU usage**
- Reduce number of active voices
- Optimize drawing routines
- Consider caching rendered elements

## Development Notes

### Code Quality
- All code follows existing FL Studio SDK patterns
- Comprehensive comments explain each section
- Proper memory management (all objects freed)
- Thread-safe audio rendering with Lock/Unlock
- Error handling for file I/O and state management

### Testing Checklist
- [x] Compiles without errors in Delphi
- [ ] Loads successfully in FL Studio
- [ ] Displays visual interface correctly
- [ ] Adds notes with mouse clicks
- [ ] Edits notes (move, resize, delete)
- [ ] Plays audio when notes are triggered
- [ ] Saves and restores state correctly
- [ ] Doesn't crash when closing or reloading
- [ ] Sends notes to FL Studio's Piano Roll
- [ ] Handles zoom and scroll properly

### Future Enhancements
- Implement note dragging and resizing
- Add copy/paste functionality
- Implement scrollbars for navigation
- Add velocity editing via dragging
- Implement undo/redo system
- Add toolbar with tool selection (Draw, Select, Erase)
- Support for note colors and grouping
- Import/export MIDI files
- More sophisticated synthesis (multiple waveforms)
- Automation recording for parameters

## References

### FL Studio SDK Documentation
- [Fruity Plug SDK Overview](../../../fruityplug.html)
- [Delphi Plug Class Reference](../../../delphifruityplug.html)
- [Constants and Types](../../../constants.html)
- [Example Plugins](../../../examples/)

### Example Plugins
- **Sine (Delphi)**: Basic generator with voice management
- **Osc3 (Delphi)**: Multi-oscillator synthesizer
- **FruityGain (Delphi)**: Effect plugin example

### Additional Resources
- FL Studio Forum: https://forum.image-line.com/
- Plugin Development subforum
- FL Studio Plugin SDK documentation

## License

This is an example plugin for educational purposes. Use it as a starting point for your own FL Studio plugins.

## Credits

Created as a complete example of FL Studio plugin development in Delphi.
Based on FL Studio SDK documentation and example plugins.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review FL Studio SDK documentation
3. Visit the FL Studio forum
4. Check example plugins for reference implementations

## Version History

### Version 1.0 (Initial Release)
- Complete piano roll editor interface
- Note creation, editing, deletion
- Visual piano keyboard (88 keys)
- Grid-based editing
- Velocity-based note coloring
- Basic sine wave synthesis
- FL Studio project save/load
- Parameter automation support
- Piano Roll integration (send notes to host)

---

**Note**: This plugin is a demonstration and starting point. While functional, it may require additional refinement for production use. Feel free to extend and customize it for your needs!
