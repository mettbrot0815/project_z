---
phase: 02-visual-assets
plan: 02
type: execute
wave: 1
depends_on:
  - "01-critical-fixes"
files_modified:
  - scenes/units/grunt.tscn
  - scenes/units/psycho.tscn
  - scenes/units/tough.tscn
  - scenes/units/sniper.tscn
  - scenes/units/laser.tscn
  - scenes/units/commander.tscn
  - scenes/units/jeep.tscn
  - scenes/units/light_tank.tscn
  - scenes/units/medium_tank.tscn
  - scenes/units/heavy_tank.tscn
  - scenes/units/apc.tscn
  - scenes/units/crane.tscn
  - scenes/units/missile_launcher.tscn
  - scenes/units/gatling.tscn
  - scenes/units/howitzer.tscn
  - scenes/buildings/factory_robot.tscn
  - scenes/buildings/factory_vehicle.tscn
  - scenes/buildings/fort.tscn
  - scenes/buildings/flag.tscn
  - scripts/core/sprite_manager.gd (new)
must_haves:
  truths:
    - "All 17 unit types have visible sprites"
    - "Player (RED team) uses red_* sprites from zod_engine"
    - "AI opponent (BLUE team) uses blue_* sprites from zod_engine"
    - "Sprite pivot points centered for proper rotation"
  artifacts:
    - path: "scripts/core/sprite_manager.gd"
      provides: "Team-based sprite selection and animation"
      exports: ["get_sprite_path", "team_to_color"]
    - path: "scenes/units/grunt.tscn"
      provides: "Sample integrated sprite with walk animation"
      exports: ["AnimatedSprite2D with walk cycle"]
  key_links:
    - from: "scenes/units/*.tscn"
      to: "scripts/core/sprite_manager.gd"
      via: "Sprite2D texture assignment"
      pattern: "sprite_manager.get_sprite_path"
---

<objective>
Add sprite assets for all units and buildings using original Z (1996) pixel art from zod_engine repository.

Purpose: Make units visible, enable gameplay testing, and establish sprite animation system.

Output: 19 scene files updated with sprites, 1 new sprite_manager script, sprite assets organized.
</objective>

<execution_context>
@C:/Users/Philipp/.config/opencode/get-shit-done/workflows/execute-plan.md
@C:/Users/Philipp/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/02-visual-assets/2-CONTEXT.md

# Asset Discovery Context

Original Z sprites at: `zod_engine-master/assets/units/`

## Naming Convention
Robots: `{action}_{team}_{direction}_{frame}.png`
- Action: walk, fire, die1, die2, etc.
- Team: blue, green, red, yellow
- Direction: r000, r045, r090, r135, r180, r225, r270, r315
- Frame: n00, n01, n02, etc.

Vehicles: `{state}_{team}_{direction}_{frame}.png`
- State: base, base_damaged
- Team: blue, green, red, yellow

## Team Mapping
Godot UnitBase.Team enum: NEUTRAL(0), RED(1), BLUE(2)
- RED (1) = Player = zod_engine "red" team sprites
- BLUE (2) = AI = zod_engine "blue" team sprites
- NEUTRAL (0) = unclaimed = zod_engine "green" team sprites

## Available Assets
- Robots: grunt/, psycho/, tough/, sniper/, laser/, pyro/
- Vehicles: jeep/, light/, medium/, heavy/, apc/, crane/, missile_launcher/
- Cannons: gatling/, gun/, howitzer/
- Buildings: robot/, vehicle/, fort/, radar/, repair/, death_effects/, exhaust/
- Effects: tank_dirt/, death_effects/, tank_missile_explosion/

## Sprite Dimensions
- Most sprites: 32x32 pixels
- Vehicles: ~32x32 base with turret overlay
- Buildings: various sizes (factory ~64x64)

</context>

<tasks>

<task type="manual">
  <name>Create asset directory structure</name>
  <files>assets/sprites/units/, assets/sprites/buildings/, assets/sprites/effects/</files>
  <action>
    Create project asset directories for organized sprite storage:
    ```
    assets/
      sprites/
        units/
          robots/
          vehicles/
          cannons/
        buildings/
        effects/
    ```
    Note: We'll reference zod_engine assets directly via absolute path rather than copying.
    This avoids duplication and keeps assets up-to-date with source.
  </action>
  <verify>Directory structure exists in project</verify>
  <done>Asset directories created</done>
</task>

<task type="auto">
  <name>Create sprite_manager.gd for team-based sprite selection</name>
  <files>scripts/core/sprite_manager.gd</files>
  <action>
    Create a centralized sprite manager script that:
    
    1. Maps Godot Team enum to zod_engine team colors:
    ```gdscript
    static func team_to_color(team: Team) -> String:
        match team:
            Team.RED: return "red"
            Team.BLUE: return "blue"
            Team.NEUTRAL: return "green"
            _: return "green"
    ```
    
    2. Provides sprite path resolution:
    ```gdscript
    static func get_robot_sprite(unit_type: String, team: Team, 
                                  action: String = "walk") -> String:
        var color = team_to_color(team)
        var base_path = "C:/Users/Philipp/Documents/GitHub/project_z/zod_engine-master/assets/units/robots/"
        return base_path + "%s/%s_%s_r000_n00.png" % [unit_type, action, color]
    ```
    
    3. Returns correct sprite paths for each unit type and team.
    
    Base path: `C:/Users/Philipp/Documents/GitHub/project_z/zod_engine-master/assets/`
  </action>
  <verify>Sprite paths resolve correctly for all teams</verify>
  <done>Sprite manager provides team-based sprite paths</done>
</task>

<task type="auto">
  <name>Update grunt.tscn with walk animation sprites</name>
  <files>scenes/units/grunt.tscn</files>
  <action>
    Modify grunt.tscn to use AnimatedSprite2D with zod_engine sprites:
    
    1. Change Sprite2D to AnimatedSprite2D
    2. Create SpriteFrames resource with "walk" animation:
       - Frames from: `zod_engine-master/assets/units/robots/grunt/`
       - Pattern: `walk_{team}_r000_n{00-09}.png`
       - Use r000 direction (facing right) for initial implementation
    3. Set animation speed to 10 FPS (original Z tick rate)
    4. Center the sprite (offset = (0, 0))
    5. Enable playing by default
    
    Example SpriteFrames structure:
    ```
    walk: [walk_red_r000_n00.png, walk_red_r000_n01.png, ..., walk_red_r000_n09.png]
    ```
  </action>
  <verify>Grunt displays walking animation when spawned</verify>
  <done>Grunt shows walk animation with correct team color</done>
</task>

<task type="auto">
  <name>Update remaining robot unit scenes</name>
  <files>
    - scenes/units/psycho.tscn
    - scenes/units/tough.tscn
    - scenes/units/sniper.tscn
    - scenes/units/laser.tscn
    - scenes/units/commander.tscn
  </files>
  <action>
    Apply same pattern as grunt.tscn to remaining robot units:
    
    For each robot type (psycho, tough, sniper, laser, commander):
    1. Replace Sprite2D with AnimatedSprite2D
    2. Create SpriteFrames with "walk" animation
    3. Use sprites from: `zod_engine-master/assets/units/robots/{unit_type}/`
    4. Pattern: `walk_{team}_r000_n{00-09}.png`
    5. Set animation speed: 10 FPS
    6. Center offset
    
    Note: pyro may have different sprite naming - check and adapt.
  </action>
  <verify>All robots display walk animations with correct colors</verify>
  <done>All 6 robot types have visible sprites</done>
</task>

<task type="auto">
  <name>Update vehicle scenes with base/damaged sprites</name>
  <files>
    - scenes/units/jeep.tscn
    - scenes/units/light_tank.tscn
    - scenes/units/medium_tank.tscn
    - scenes/units/heavy_tank.tscn
    - scenes/units/apc.tscn
    - scenes/units/crane.tscn
    - scenes/units/missile_launcher.tscn
  </files>
  <action>
    For each vehicle:
    1. Replace Sprite2D with AnimatedSprite2D
    2. Create SpriteFrames with animations:
       - "base": base_{team}_r000_n{00-02}.png
       - "damaged": base_damaged_{team}_r000_n{00-02}.png
    3. Source: `zod_engine-master/assets/units/vehicles/{type}/`
    4. Mapping:
       - jeep → jeep/
       - light_tank → light/
       - medium_tank → medium/
       - heavy_tank → heavy/
       - apc → apc/
       - crane → crane/
       - missile_launcher → missile_launcher/
    5. Speed: 10 FPS, centered offset
  </action>
  <verify>Vehicles display base sprites, switch to damaged on low HP</verify>
  <done>All 7 vehicle types have base and damaged animations</done>
</task>

<task type="auto">
  <name>Update cannon unit scenes</name>
  <files>
    - scenes/units/gatling.tscn
    - scenes/units/howitzer.tscn
  </files>
  <action>
    For cannons (stationary guns):
    1. Replace Sprite2D with AnimatedSprite2D
    2. Use sprites from: `zod_engine-master/assets/units/cannons/`
    3. Gatling: sprites from gatling/ subdirectory
    4. Howitzer: sprites from howitzer/ subdirectory
    5. Team color handling: same pattern as robots
    6. Direction: start with r000, add more directions if time permits
  </action>
  <verify>Cannons display with correct team colors</verify>
  <done>Gatling and howitzer have visible sprites</done>
</task>

<task type="auto">
  <name>Add team color switching to all units</name>
  <files>scripts/core/unit_base.gd</files>
  <action>
    Modify UnitBase to dynamically switch sprite textures based on team:
    
    1. Add _ready() code to load correct team sprite:
    ```gdscript
    var _sprite: AnimatedSprite2D
    var _current_team: Team
    
    func _ready() -> void:
        super._ready()
        _sprite = $AnimatedSprite2D
        _update_team_sprites()
    
    func _update_team_sprites() -> void:
        if _sprite and _sprite.sprite_frames:
            var frames = _sprite.sprite_frames
            var anims = frames.get_animation_names()
            var color = SpriteManager.team_to_color(team)
            # Update all animations with correct team color
    ```
    
    2. Connect team_changed signal to refresh sprites:
    ```gdscript
    func _on_team_changed(new_team: Team) -> void:
        _update_team_sprites()
    ```
  </action>
  <verify>Units change sprite color when team changes</verify>
  <done>Team color switching works for all units</done>
</task>

<task type="auto">
  <name>Update building scenes with factory/fort sprites</name>
  <files>
    - scenes/buildings/factory_robot.tscn
    - scenes/buildings/factory_vehicle.tscn
    - scenes/buildings/fort.tscn
  </files>
  <action>
    For each building:
    1. Use sprites from: `zod_engine-master/assets/buildings/`
    2. factory_robot → robot/ subdirectory
    3. factory_vehicle → vehicle/ subdirectory
    4. fort → fort/ subdirectory
    5. Set appropriate scale for building size (may need 2x-4x scale)
    6. Static buildings - no animation needed initially
    
    Note: Buildings may have larger sprite sizes, adjust collision shape accordingly.
  </action>
  <verify>Buildings display factory/fort sprites</verify>
  <done>Factory and fort buildings have visible sprites</done>
</task>

<task type="auto">
  <name>Update flag scene with team-colored flags</name>
  <files>scenes/buildings/flag.tscn</files>
  <action>
    Flag sprites from zod_engine:
    1. Check buildings/ for flag sprites
    2. Support 4 team colors: red, green, blue, yellow
    3. Simple Sprite2D (not AnimatedSprite2D)
    4. Team color handled via sprite switching
    5. Scale appropriately for visibility
    
    Note: If no flag sprites found, create placeholder or use terrain color indicator.
  </action>
  <verify>Flags display with correct team colors</verify>
  <done>Flags show team colors</done>
</task>

<task type="checkpoint:human-verify">
  <what-built>All unit and building sprites integrated</what-built>
  <how-to-verify>
    1. Open project in Godot 4.6
    2. Start a test level
    3. Spawn units from factory
    4. Check all unit types display visible sprites
    5. Verify player units are red, AI units are blue
    6. Test team color switching by capturing territory
    7. Verify vehicle damage states switch at appropriate HP thresholds
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

<verification>
- All 17 unit types display visible sprites
- RED team uses red_* sprites (player)
- BLUE team uses blue_* sprites (AI)
- Sprite animations play at correct speed (10 FPS)
- Team color switching works
- Building sprites display correctly
</verification>

<success_criteria>
- All unit scenes (.tscn) have sprite textures assigned
- Units are visible when spawned
- Team colors match: RED = player (red sprites), BLUE = AI (blue sprites)
- Buildings (factory, fort, flag) have visible sprites
- No broken sprite references in console
- Game is playable with visible units
</success_criteria>
