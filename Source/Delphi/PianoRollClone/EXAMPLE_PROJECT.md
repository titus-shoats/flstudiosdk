# Example FL Studio Project Setup

This document describes how to set up an FL Studio project to demonstrate the Piano Roll Clone plugin.

## Creating a Demo Project

### Step 1: Load the Plugin

1. Open FL Studio
2. In the Channel Rack, click an empty slot or press Shift+F6
3. Navigate to: **Generators → PianoRollClone**
4. Click to add the plugin

### Step 2: Open the Editor

1. Click the plugin name in the Channel Rack
2. The Piano Roll Clone editor window will open
3. You should see:
   - Piano keyboard on the left (88 keys)
   - Grid in the center
   - Dark theme matching FL Studio

### Step 3: Add Some Notes

1. Click in the grid area to add notes
2. Try adding a simple melody:
   - C4 (middle C) at position 0
   - E4 at position 96 (one beat later)
   - G4 at position 192 (two beats later)
   - C5 at position 288 (three beats later)

### Step 4: Play the Pattern

1. Close the editor or keep it open
2. In FL Studio, press Space to play
3. You should hear a simple sine wave playing your notes

### Step 5: Adjust Parameters

In the channel settings or wrapper, adjust:
- **Grid Snap**: Change to 1/8 or 1/32 for finer note placement
- **Volume**: Adjust overall volume (0-100%)
- **Pan**: Adjust stereo position (-64 to +64)
- **Zoom X**: Change horizontal view (50-200%)
- **Zoom Y**: Change vertical view (50-200%)

### Step 6: Save the Project

1. File → Save as...
2. Name it "PianoRollClone_Demo.flp"
3. Save anywhere
4. Close and reopen - notes should be preserved

### Step 7: Send to FL Studio Piano Roll (Optional)

1. Open the plugin editor
2. In code, call SendNotesToHost method (requires implementation in UI)
3. Notes will appear in FL Studio's native Piano Roll
4. You can then edit them with FL Studio's advanced features

## Example Patterns to Try

### Simple Melody
```
C4  (60) at 0   - Length 96  - Velocity 100
D4  (62) at 96  - Length 96  - Velocity 90
E4  (64) at 192 - Length 96  - Velocity 100
F4  (65) at 288 - Length 96  - Velocity 90
G4  (67) at 384 - Length 96  - Velocity 100
```

### Chord Progression (C Major)
```
C4  (60) at 0   - Length 384 - Velocity 100
E4  (64) at 0   - Length 384 - Velocity 90
G4  (67) at 0   - Length 384 - Velocity 80

F3  (53) at 384 - Length 384 - Velocity 100
A3  (57) at 384 - Length 384 - Velocity 90
C4  (60) at 384 - Length 384 - Velocity 80
```

### Arpeggio Pattern
```
C4  (60) at 0   - Length 48  - Velocity 100
E4  (64) at 48  - Length 48  - Velocity 90
G4  (67) at 96  - Length 48  - Velocity 80
C5  (72) at 144 - Length 48  - Velocity 100
G4  (67) at 192 - Length 48  - Velocity 90
E4  (64) at 240 - Length 48  - Velocity 80
C4  (60) at 288 - Length 48  - Velocity 100
```

## MIDI Note Reference

Common notes for testing:

| Note | MIDI # | Frequency | Description |
|------|--------|-----------|-------------|
| C3   | 48     | 130.81 Hz | Low C |
| C4   | 60     | 261.63 Hz | Middle C |
| E4   | 64     | 329.63 Hz | E above middle C |
| G4   | 67     | 392.00 Hz | G above middle C |
| C5   | 72     | 523.25 Hz | High C |

## Parameter Values

### Grid Snap (Parameter 0)
- **4**: 1/4 note (coarse)
- **8**: 1/8 note
- **16**: 1/16 note (default, good for most purposes)
- **32**: 1/32 note (fine editing)

### Zoom X (Parameter 1)
- **50**: 50% zoom (see more time)
- **100**: 100% zoom (default, 1:1)
- **150**: 150% zoom (closer view)
- **200**: 200% zoom (maximum close-up)

### Zoom Y (Parameter 2)
- **50**: 50% zoom (see more notes vertically)
- **100**: 100% zoom (default)
- **200**: 200% zoom (larger note display)

### Volume (Parameter 3)
- **0**: Silent
- **50**: Half volume
- **80**: Default volume
- **100**: Full volume

### Pan (Parameter 4)
- **-64**: Full left
- **0**: Center (default)
- **64**: Full right

## Demonstration Workflow

### Basic Workflow
1. Add plugin to channel
2. Open editor
3. Click to add notes
4. Press Play in FL Studio
5. Hear the result
6. Save project

### Advanced Workflow
1. Add plugin to channel
2. Open editor
3. Create a melody pattern
4. Adjust grid snap for fine-tuning
5. Adjust velocity (through color coding)
6. Use zoom to see details
7. Send to FL Studio Piano Roll
8. Edit in FL Studio for advanced features
9. Save project

## Tips for Demonstration

1. **Start Simple**: Add just 3-4 notes to hear it work
2. **Use Middle C**: Note 60 (C4) is easy to find
3. **Grid Snapping**: Keep default 1/16 for easy alignment
4. **Velocity**: Higher values = brighter blue color
5. **Listen**: Press Space in FL Studio to hear playback
6. **Save Often**: Plugin saves state with project

## Troubleshooting Demo Issues

**No sound when playing**:
- Check FL Studio's master volume
- Check channel volume fader
- Ensure notes are added (visible in editor)
- Check that notes are in playback range

**Can't add notes**:
- Make sure editor is open
- Click in the grid area (right of piano keys)
- Check that you're in Draw mode (default)

**Notes disappear**:
- Check if you accidentally deleted them
- Reload the project file
- Notes should persist when saved

**Visual issues**:
- Close and reopen editor
- Check screen resolution
- Ensure graphics drivers are updated

## Sample Project Contents

A typical demo project would contain:
- 1 channel with PianoRollClone
- 4-8 bars of pattern
- Simple melody or chord progression
- Tempo: 120 BPM (default)
- Pattern length: 4 bars (384 PPQ)

## Next Steps

After the basic demo:
1. Try more complex melodies
2. Experiment with velocity colors
3. Test save/load functionality
4. Try different grid snaps
5. Explore zoom features
6. Test integration with FL Studio's Piano Roll

---

**Note**: This is a demonstration plugin. For production music, use FL Studio's native Piano Roll which has many more features. This plugin is designed to show how to create a custom FL Studio plugin in Delphi.
