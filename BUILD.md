# Build Instructions

This document explains how to build and export the Z game for various platforms.

## Prerequisites

### Godot Engine
- Download from https://godotengine.org/download/
- Version 4.3 or higher required
- Choose "Forward Plus" renderer

### Platform Requirements

#### Windows
- Windows 10/11
- 4GB RAM minimum
- DirectX 11 compatible GPU

#### Linux
- Ubuntu 20.04+ / Fedora 35+
- 4GB RAM minimum
- OpenGL 3.3+ compatible GPU

#### macOS
- macOS 11+ (Big Sur)
- 8GB RAM recommended
- Metal compatible GPU

#### Web (HTML5)
- Modern browser (Chrome, Firefox, Edge)
- WebGL support
- 4GB RAM minimum

## Quick Start

### Development
```bash
# Open in Godot
godot --path . --run "res://scenes/Main.tscn"

# Or simply double-click the .godot file
```

### Run
```bash
# Windows
godot --path . --run "res://scenes/Main.tscn"

# Linux
godot --path . --run "res://scenes/Main.tscn"

# macOS
godot --path . --run "res://scenes/Main.tscn"
```

## Exporting

### Windows
```bash
# Debug build
godot --path . --export "Windows Desktop" project_z/

# Release build
godot --path . --export-release "Windows Desktop" project_z/
```

### Linux
```bash
# Debug build
godot --path . --export "Linux/X11" project_z/

# Release build
godot --path . --export-release "Linux/X11" project_z/
```

### macOS
```bash
# Debug build
godot --path . --export "MacOS" project_z/

# Release build
godot --path . --export-release "MacOS" project_z/
```

### Web (HTML5)
```bash
# Debug build
godot --path . --export "Web" project_z/

# Release build (optimizes for web)
godot --path . --export-release "Web" project_z/
```

## Export Presets

Edit `export_presets.cfg` to add custom export presets:

```ini
[preset.6]
name="Custom Name"
platform="Custom Platform"
runnable=true
advanced_options=false
dedicated_server_mode=false
feature="4.3"
scripting_customizations=""
text_to_speech_enabled=true
config/features=PackedStringArray()
```

## Build Options

### Performance Settings

#### Quality Level
```ini
# In export_presets.cfg
config/features=PackedStringArray("gl_compatibility", "high_performance")
```

Options:
- `gl_compatibility` - Better compatibility
- `forward_plus` - Better quality, more demanding
- `high_performance` - Optimized for lower-end hardware

#### Resolution
```ini
window/size/viewport_width=1280
window/size/viewport_height=720
```

### Window Settings

#### Fullscreen
```ini
window/window_mode="windowed"  # or "fullscreen"
```

#### Borderless
```ini
window/window_mode="borderless"
```

#### Size
```ini
window/size/viewport_width=1280
window/size/viewport_height=720
```

### Audio Settings

#### Sample Rate
```ini
audio/sample_rate=48000
```

#### Buffer Size
```ini
audio/buffer_size=256
```

## Build Scripts

### Windows Batch File (build.bat)
```batch
@echo off
echo Building Z Game for Windows...
godot --path . --export "Windows Desktop" project_z
echo Build complete! Output in project_z folder.
pause
```

### Linux Shell Script (build.sh)
```bash
#!/bin/bash
echo "Building Z Game for Linux..."
godot --path . --export "Linux/X11" project_z
echo "Build complete! Output in project_z folder."
```

### macOS Script (build.sh)
```bash
#!/bin/bash
echo "Building Z Game for macOS..."
godot --path . --export "MacOS" project_z
echo "Build complete! Output in project_z folder."
```

## Package Distribution

### Windows
```bash
# Create installer
nsis project_z/ ZSetup.exe

# Or use zip
zip -r Z_Game Windows/
```

### Linux
```bash
# Create archive
tar -czf Z_Game.tar.gz Linux/

# Or use appimage
appimage project_z/ Z_Game.AppImage
```

### macOS
```bash
# Create DMG
hdiutil create -volname "Z Game" -srcfolder project_z/ Z_Game.dmg
```

### Web
```bash
# Already packaged by Godot export
# Just copy the .html file
```

## Testing

### Before Release
```bash
# Run all export presets
for preset in "Windows Desktop" "Linux/X11" "MacOS" "Web"; do
    godot --path . --export "$preset" project_z
done

# Test each build
./project_z/Windows/Z.exe
./project_z/Linux/Z
open project_z/MacOS/Z.app
```

### Check Build
- [ ] Runs without errors
- [ ] All levels load
- [ ] Audio works
- [ ] Controls responsive
- [ ] No crashes
- [ ] Performance acceptable
- [ ] UI readable

## Troubleshooting

### Build Fails
```bash
# Clear project cache
rm -rf .godot/
rm -rf project_z/

# Rebuild
godot --path . --export "Platform" project_z/
```

### Export Issues
- Check `export_presets.cfg` syntax
- Verify Godot version compatibility
- Update Godot if needed
- Check platform-specific requirements

### Runtime Issues
- Verify all assets are included
- Check dependencies
- Review console output
- Test on clean install

## Performance Tuning

### Low-End Systems
```ini
# In export_presets.cfg
config/features=PackedStringArray("gl_compatibility", "high_performance")
window/size/viewport_width=800
window/size/viewport_height=600
```

### High-End Systems
```ini
config/features=PackedStringArray("forward_plus")
window/size/viewport_width=1920
window/size/viewport_height=1080
```

## Version Control

### Git Setup
```bash
# Initialize git
git init

# Add files
git add .

# Commit
git commit -m "Initial commit"

# Push
git remote add origin <repository-url>
git push -u origin main
```

## Release Process

1. Update CHANGELOG.md
2. Update version in project.godot
3. Test all platforms
4. Create release assets
5. Write release notes
6. Create GitHub release
7. Update itch.io/GitHub Pages

## Distribution

### itch.io
- Upload exported folder
- Set platform tags
- Configure pricing
- Add screenshots

### GitHub Pages
- Upload exported folder
- Configure _config.yml
- Set up hosting

### Direct Download
- Package as zip/tar
- Include README.md
- Include LICENSE
- Include setup instructions

## Support

### Build Issues
- Check Godot version
- Verify platform requirements
- Review error messages
- Check export preset config

### Runtime Issues
- Verify file integrity
- Check system requirements
- Review logs
- Test on clean install

---

**Build Status**: Ready for export
**Last Updated**: 2026-03-31
**Godot Version**: 4.3+
