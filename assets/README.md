# Assets Directory

This directory contains all game assets. Placeholder files are included as templates.

## Required Assets

### Sprites (PNG)

#### Units
- `units/grunt.png` - Basic infantry robot
- `units/psycho.png` - Machine gun robot
- `units/tough.png` - High armor robot
- `units/sniper.png` - Long range sniper
- `units/pyro.png` - Flamethrower robot
- `units/laser.png` - Energy weapon robot
- `units/jeep.png` - Fast reconnaissance vehicle
- `units/apc_light.png` - Light armored personnel carrier
- `units/tank_light.png` - Light tank
- `units/tank_medium.png` - Medium tank
- `units/tank_heavy.png` - Heavy tank
- `units/armored_car.png` - Armored car
- `units/mortar.png` - Mortar vehicle
- `units/transport.png` - Transport vehicle
- `units/command_vehicle.png` - Command vehicle

#### Structures
- `structures/fort_red.png` - Red team fort
- `structures/fort_blue.png` - Blue team fort
- `structures/factory_robot.png` - Robot factory
- `structures/factory_vehicle.png` - Vehicle factory
- `structures/gatling.png` - Gatling gun
- `structures/howitzer.png` - Howitzer
- `structures/missile.png` - Missile launcher
- `structures/turret.png` - Turret

#### Terrain
- `terrain/desert.png` - Desert terrain
- `terrain/volcanic.png` - Volcanic terrain
- `terrain/arctic.png` - Arctic terrain
- `terrain/jungle.png` - Jungle terrain
- `terrain/city.png` - City terrain
- `terrain/flag_neutral.png` - Neutral flag
- `terrain/flag_red.png` - Red team flag
- `terrain/flag_blue.png` - Blue team flag

### Tiles (PNG)

#### Ground Tiles
- `tiles/desert_ground.png` - Desert ground
- `tiles/volcanic_ground.png` - Volcanic ground
- `tiles/arctic_ground.png` - Arctic ground
- `tiles/jungle_ground.png` - Jungle ground
- `tiles/city_ground.png` - City ground

#### Terrain Features
- `tiles/desert_dunes.png` - Desert dunes
- `tiles/desert_oasis.png` - Desert oasis
- `tiles/volcanic_lava.png` - Lava flow
- `tiles/volcanic_crater.png` - Crater
- `tiles/arctic_ice.png` - Ice sheet
- `tiles/arctic_glacier.png` - Glacier
- `tiles/jungle_trees.png` - Jungle trees
- `tiles/jungle_canopy.png` - Canopy
- `tiles/city_buildings.png` - City buildings
- `tiles/city_roofs.png` - Rooftops

### UI Elements (PNG)

#### HUD
- `ui/hud_bg.png` - HUD background
- `ui/unit_panel.png` - Unit info panel
- `ui/minimap_bg.png` - Minimap background
- `ui/selection_box.png` - Unit selection highlight
- `ui/health_bar.png` - Health bar
- `ui/selection_ring.png` - Unit selection ring

#### Buttons
- `ui/pause_button.png` - Pause button
- `ui/menu_button.png` - Menu button
- `ui/victory_screen.png` - Victory screen
- `ui/defeat_screen.png` - Defeat screen
- `ui/next_level_button.png` - Next level button

### Icons (PNG)

#### Unit Icons
- `icons/grunt_icon.png` - Grunt icon
- `icons/psycho_icon.png` - Psycho icon
- `icons/tough_icon.png` - Tough icon
- `icons/sniper_icon.png` - Sniper icon
- `icons/pyro_icon.png` - Pyro icon
- `icons/laser_icon.png` - Laser icon

#### Factory Icons
- `icons/factory_robot_icon.png` - Robot factory icon
- `icons/factory_vehicle_icon.png` - Vehicle factory icon

### Sounds (WAV or OGG)

#### SFX
- `sfx/selection.wav` - Unit selection sound
- `sfx/capture.wav` - Flag capture sound
- `sfx/attack.wav` - Attack sound
- `sfx/damage.wav` - Damage sound
- `sfx/explosion.wav` - Explosion sound
- `sfx/death.wav` - Unit death sound
- `sfx/production.wav` - Unit production complete
- `sfx/build.wav` - Building construction
- `sfx/menu.wav` - Menu navigation

#### Music
- `music/main_theme.ogg` - Main theme
- `music/battle.ogg` - Battle music
- `music/victory.ogg` - Victory theme
- `music/defeat.ogg` - Defeat theme
- `music/menu.ogg` - Menu background

### Cutscenes

#### Story Scenes
- `cutscenes/intro.mp4` - Intro cutscene
- `cutscenes/level_complete.mp4` - Level complete
- `cutscenes/victory.mp4` - Victory celebration
- `cutscenes/defeat.mp4` - Defeat screen
- `cutscenes/rocket_party.mp4` - Rocket fuel party

## Placeholder Assets

Placeholder graphics are included for development. Replace with:

1. High-quality pixel art (32x32 to 64x64 for units)
2. Consistent art style across all assets
3. Proper color palette (red vs blue theme)
4. Smooth animations for movement/attacks

### Creating Assets

#### Tools
- Aseprite (recommended for pixel art)
- Photoshop
- GIMP
- Blender (for 3D conversions)

#### Guidelines
- Use original Z art style as reference
- Maintain 16-color or 32-color palette
- Include transparency
- Optimize file sizes
- Test at game resolution

## Asset Sizes

### Recommended
- Units: 32x32 to 64x64 pixels
- Sprites: 64x64 to 128x128 pixels
- UI elements: 128x128 to 256x256 pixels
- Terrain: 64x64 to 128x128 pixels

### File Formats
- Sprites: PNG (lossless compression)
- UI: PNG with transparency
- Sounds: WAV or OGG (compressed)
- Music: OGG or MP3 (compressed)
- Cutscenes: MP4 or WebM

## Import Settings

### Godot Import
```gdscript
# In Godot, configure import settings
compression_mode = "PNG"
quality = 100
simplify = false
```

### Performance
- Use PNG for sprites
- Use OGG for audio (smaller)
- Limit texture sizes to 512x512
- Use atlases for sprites

## License

All original Z assets remain property of The Bitmap Brothers.

This project uses placeholder assets for development.

Replace with:
- Original Bitmap Brothers assets (with permission)
- Compatible fan art
- Original-style recreation

## Credits

When assets are added, credit:
- Original artists (if using fan art)
- Bitmap Brothers (for original game)
- Any asset creators

---

**Status**: Placeholder assets in use
**Target**: Complete sprite art with original style
**Priority**: High
