# Quick Start Guide - FL Studio Hello World Plugin

This guide will walk you through building and running your first FL Studio native plugin with JUCE GUI.

## Prerequisites Checklist

- [ ] Windows OS (or Wine for Linux)
- [ ] CMake 3.15 or higher
- [ ] C++ Compiler (Visual Studio 2019+ recommended)
- [ ] Git (for cloning JUCE)
- [ ] FL Studio (for testing)

## Step-by-Step Instructions

### 1. Clone or Download This Repository

```bash
git clone https://github.com/titus-shoats/flstudiosdk.git
cd flstudiosdk
```

### 2. Navigate to the Example

```bash
cd examples/HelloWorldPlugin
```

### 3. Create Build Directory

```bash
mkdir build
cd build
```

### 4. Configure with CMake

**For Visual Studio 2019:**
```bash
cmake .. -G "Visual Studio 16 2019" -A x64
```

**For Visual Studio 2022:**
```bash
cmake .. -G "Visual Studio 17 2022" -A x64
```

**For MinGW:**
```bash
cmake .. -G "MinGW Makefiles"
```

This step will:
- Download JUCE framework from GitHub (may take a few minutes)
- Configure the build system
- Set up all dependencies

### 5. Build the Plugin

```bash
cmake --build . --config Release
```

This creates `HelloWorld.dll` in the `Release` folder.

### 6. Install the Plugin in FL Studio

1. Find your FL Studio installation directory (usually `C:\Program Files\Image-Line\FL Studio 20\`)

2. Create this folder structure:
   ```
   <FL Studio>\Plugins\Fruity\Generators\HelloWorld\
   ```

3. Copy `HelloWorld.dll` from `build/Release/` to the folder you just created:
   ```
   <FL Studio>\Plugins\Fruity\Generators\HelloWorld\HelloWorld.dll
   ```

### 7. Launch FL Studio

1. Start FL Studio
2. In the channel rack, click the "+" button
3. Navigate to: `Generators` → `HelloWorld`
4. Click to add the plugin to a channel

### 8. Open the Plugin Window

1. Click the channel button in the channel rack
2. The Hello World window should appear showing:
   - Blue gradient background
   - "Hello World" text in white (centered)
   - Subtitle text below

## Troubleshooting

### CMake can't find JUCE

**Problem:** Download fails or network issues

**Solution:** 
1. Clone JUCE manually:
   ```bash
   git clone --depth 1 --branch 7.0.9 https://github.com/juce-framework/JUCE.git
   ```
2. Use the system JUCE:
   ```bash
   cmake .. -DUSE_SYSTEM_JUCE=ON -DJUCE_DIR=/path/to/JUCE
   ```

### Build Errors

**Problem:** Compiler errors about missing headers

**Solution:**
- Make sure you're using Visual Studio 2019 or later
- Check that Windows SDK is installed
- Try cleaning and rebuilding:
  ```bash
  cmake --build . --clean-first
  ```

### Plugin Not Found in FL Studio

**Problem:** Plugin doesn't appear in FL Studio menu

**Solution:**
1. Check folder structure matches exactly:
   ```
   Plugins/Fruity/Generators/HelloWorld/HelloWorld.dll
   ```
2. Verify folder name matches DLL name (without .dll extension)
3. Restart FL Studio
4. Check FL Studio's plugin scanner settings

### Plugin Window Doesn't Appear

**Problem:** Plugin loads but window is blank or doesn't show

**Solution:**
1. Check Event Viewer for errors
2. Verify JUCE dependencies are included in DLL
3. Try running FL Studio as administrator
4. Check that you built 64-bit DLL for 64-bit FL Studio (or 32-bit for 32-bit)

### Wrong Architecture Error

**Problem:** "The plugin could not be loaded" error

**Solution:**
- FL Studio 64-bit needs 64-bit plugin (use `-A x64` in CMake)
- FL Studio 32-bit needs 32-bit plugin (use `-A Win32` in CMake)
- Rebuild with correct architecture

## Verification Checklist

After following these steps, verify:

- [ ] `HelloWorld.dll` exists in `build/Release/`
- [ ] DLL is copied to correct FL Studio folder
- [ ] Folder name matches: `HelloWorld` (no .dll)
- [ ] FL Studio shows plugin in Generators menu
- [ ] Plugin window opens when clicked
- [ ] Window shows blue gradient background
- [ ] "Hello World" text is visible and centered

## Next Steps

Once you have the Hello World plugin working:

1. **Explore the Code:**
   - Open `src/HelloWorldPlugin.cpp` to see FL Studio integration
   - Open `src/HelloWorldEditor.cpp` to see JUCE GUI code

2. **Modify the GUI:**
   - Change the gradient colors
   - Modify the text
   - Add more JUCE components

3. **Add Functionality:**
   - Implement audio generation in `Voice_Render()`
   - Add parameters to control the plugin
   - Add MIDI input handling

4. **Read the Documentation:**
   - Check `ARCHITECTURE.md` for technical details
   - Browse the HTML documentation in the SDK root
   - Visit JUCE tutorials: https://docs.juce.com/

## Getting Help

If you're stuck:

1. Review the `README.md` in the HelloWorldPlugin folder
2. Check the `ARCHITECTURE.md` for technical details
3. Open `preview.html` in a browser to see what the plugin should look like
4. Review the FL Studio SDK HTML documentation in the repository root

## Common Build Commands Reference

```bash
# Clean build
cmake --build . --clean-first

# Build in Debug mode (for debugging)
cmake --build . --config Debug

# Rebuild CMake configuration
cd build
rm CMakeCache.txt
cmake ..

# View build output verbosely
cmake --build . --config Release --verbose
```

## File Locations Quick Reference

```
flstudiosdk/
├── sdk/include/              # FL Studio SDK headers
├── examples/HelloWorldPlugin/
│   ├── CMakeLists.txt       # Build configuration
│   ├── src/                 # Source code
│   └── build/               # Build output (you create this)
│       └── Release/
│           └── HelloWorld.dll  # The plugin!
└── Plugins/Fruity/Generators/HelloWorld/  # FL Studio install location
    └── HelloWorld.dll       # Copy here
```

## Success!

If you've made it this far and the plugin is working, congratulations! 🎉

You now have:
- A working FL Studio native plugin
- JUCE GUI integration
- A foundation to build more complex plugins

Happy coding! 🚀
