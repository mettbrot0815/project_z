---
phase: 04-audio-polish
plan: 01
type: execute
wave: 1
depends_on:
  - "03-ai-opponent"
files_modified:
  - scripts/core/combat_manager.gd
  - scripts/units/unit_base.gd
  - scripts/units/vehicle_base.gd
  - scripts/game/game_manager.gd
  - project.godot
must_haves:
  truths:
    - "Units make sound when firing"
    - "Explosions produce sound and particles"
    - "Units play voice barks when moving/attacking/dying"
    - "Background music plays during gameplay"
  artifacts:
    - path: "scripts/core/audio_manager.gd"
      provides: "Centralized audio playback and sound pooling"
      exports: ["play_sound()", "play_music()", "sound_pool"]
    - path: "scripts/effects/explosion_effect.gd"
      provides: "Particle explosion with sound"
      exports: ["explode()", "particles"]
---

<objective>
Add audio and visual polish: sound effects, voice barks, particle effects, and background music.

Purpose: Make game immersive and provide audio feedback for combat actions.

Output: Audio manager, explosion effects, sound integration.
</objective>

<execution_context>
@C:/Users/Philipp/.config/opencode/get-shit-done/workflows/execute-plan.md
@C:/Users/Philipp/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/CODE_MAP.md
@.planning/ROADMAP.md
@.planning/research/FEATURES.md

# Audio & Polish Context

## Existing Systems
- CombatManager: Handles projectile physics and collision
- UnitBase: Units have take_damage(), die(), fire actions
- VehicleBase: kill_driver() for vehicle destruction
- FlyingTurret: Tank death effect

## Sound Sources (to be created)
Original Z sounds available in zod_engine:
- guns/: Gunshot sounds for each weapon type
- explosions/: Explosion sounds
- barks/: Voice barks (move, attack, die, victory)
- music/: Background music tracks

## Particle Effects Needed
- Explosion particles (on unit death)
- Muzzle flash (on firing)
- Smoke/damage (on low HP)
- Selection indicator

## Audio Integration Points
1. Unit fires weapon → play gunshot sound
2. Unit takes damage → play damage sound
3. Unit dies → play death sound + explosion
4. Territory captured → play capture sound
5. Factory completes unit → play completion sound

</context>

<tasks>

<task type="manual">
  <name>Create audio manager singleton</name>
  <files>scripts/core/audio_manager.gd</files>
  <action>
    Create centralized audio manager for all game sounds:
    
    1. Add to project.godot autoloads as `AudioManager`
    
    2. Key properties:
    ```gdscript
    var master_volume: float = 1.0
    var sfx_volume: float = 1.0
    var music_volume: float = 0.7
    var voice_volume: float = 1.0
    
    var _sound_pool: Dictionary = {}
    var _music_player: AudioStreamPlayer
    var _sfx_player: AudioStreamPlayer
    var _voice_player: AudioStreamPlayer
    ```
    
    3. Key methods:
    - `play_sound(sound_name: String, volume_db: float = 0.0)` - Play one-shot sound
    - `play_music(track_name: String, fade_in: bool = true)` - Play background music
    - `stop_music(fade_out: bool = true)` - Stop background music
    - `set_master_volume(vol: float)` - Set master volume
    - `set_sfx_volume(vol: float)` - Set SFX volume
    - `set_music_volume(vol: float)` - Set music volume
    
    4. Sound pooling for frequently-used sounds (gunshots)
  </action>
  <verify>AudioManager exists and can play sounds</verify>
  <done>Audio manager singleton created</done>
</task>

<task type="auto">
  <name>Create explosion effect scene</name>
  <files>scenes/effects/explosion.tscn, scripts/effects/explosion_effect.gd</files>
  <action>
    Create reusable explosion particle effect:
    
    1. Create explosion.tscn:
    ```
    - Node2D (root)
      - CPUParticles2D (explosion particles)
      - PointLight2D (flash effect)
      - AudioStreamPlayer (explosion sound)
    ```
    
    2. Configure CPUParticles2D:
    - Amount: 20
    - Lifetime: 0.5
    - Direction: radial (360 degrees)
    - Initial velocity: 100-200
    - Gravity: 0 (space explosion)
    - Color: Orange → Red → Dark (gradient)
    - Scale: 0.5 → 0.0 (shrink)
    
    3. explosion_effect.gd script:
    ```gdscript
    extends Node2D
    
    func explode(position: Vector2, scale: float = 1.0) -> void:
        global_position = position
        $CPUParticles2D.emitting = true
        $PointLight2D.enabled = true
        AudioManager.play_sound("explosion")
        
        await get_tree().create_timer(0.5).timeout
        queue_free()
    ```
    
    4. Add to combat_manager for projectile impacts
  </action>
  <verify>Explosion appears on projectile impact</verify>
  <done>Explosion effect created</done>
</task>

<task type="auto">
  <name>Add unit death effects</name>
  <files>scripts/core/unit_base.gd, scripts/core/combat_manager.gd</files>
  <action>
    Add visual and audio feedback for unit death:
    
    1. Modify UnitBase.die():
    ```gdscript
    func die(killer: Node2D) -> void:
        died.emit(killer)
        
        # Play death sound
        AudioManager.play_sound("unit_death")
        
        # Spawn small explosion
        spawn_death_effect()
        
        queue_free()
    
    func spawn_death_effect() -> void:
        var explosion = preload("res://scenes/effects/explosion.tscn").instantiate()
        explosion.explode(global_position, 0.5)
        get_tree().current_scene.add_child(explosion)
    ```
    
    2. Modify VehicleBase.kill_driver() for vehicles:
    ```gdscript
    func kill_driver() -> void:
        # Spawn explosion
        var explosion = preload("res://scenes/effects/explosion.tscn").instantiate()
        explosion.explode(global_position, 1.0)
        get_parent().add_child(explosion)
        
        AudioManager.play_sound("vehicle_explosion")
        
        # Spawn flying turret effect
        # ... existing code ...
    ```
  </action>
  <verify>Units explode on death with sound</verify>
  <done>Death effects added</done>
</task>

<task type="auto">
  <name>Add firing sound effects</name>
  <files>scripts/core/combat_manager.gd</files>
  <action>
    Add sound when units fire weapons:
    
    1. Modify CombatManager.fire_projectile():
    ```gdscript
    func fire_projectile(from: Vector2, to: Vector2, damage: float, shooter: Node2D) -> void:
        # ... existing code ...
        
        # Play firing sound based on unit type
        if shooter.has_method("get_unit_type"):
            var unit_type = shooter.get_unit_type()
            play_fire_sound(unit_type)
    
    func play_fire_sound(unit_type: String) -> void:
        match unit_type:
            "grunt", "psycho":
                AudioManager.play_sound("gunshot_light")
            "sniper", "laser":
                AudioManager.play_sound("gunshot_heavy")
            "gatling":
                AudioManager.play_sound("gatling_fire")
            "howitzer":
                AudioManager.play_sound("cannon_fire")
            "missile_launcher":
                AudioManager.play_sound("missile_launch")
            _:
                AudioManager.play_sound("gunshot_default")
    ```
    
    2. Add muzzle flash effect:
    ```gdscript
    func spawn_muzzle_flash(position: Vector2, direction: Vector2) -> void:
        var flash = CPUParticles2D.new()
        flash.emitting = true
        flash.one_shot = true
        flash.amount = 5
        flash.lifetime = 0.1
        flash.direction = direction
        flash.initial_velocity_min = 50
        flash.initial_velocity_max = 100
        flash.spread = 30
        flash.color = Color.YELLOW
        flash.global_position = position
        get_tree().current_scene.add_child(flash)
        flash.tree_exiting.connect(flash.queue_free)
    ```
  </action>
  <verify>Gunfire sounds play when units fire</verify>
  <done>Firing sounds added</done>
</task>

<task type="auto">
  <name>Add voice bark system</name>
  <files>scripts/core/audio_manager.gd</files>
  <action>
    Add voice barks for unit actions:
    
    1. Extend AudioManager:
    ```gdscript
    func play_voice_bark(bark_type: String, team: int) -> void:
        # Only play barks occasionally to avoid spam
        if randf() > 0.1:  # 10% chance
            return
        
        var bark_path = "res://assets/audio/voices/%s/%s_%d.ogg" % [
            bark_type,
            _get_team_prefix(team),
            randi() % 3  # Random variant 0-2
        ]
        
        if ResourceLoader.exists(bark_path):
            _voice_player.stream = load(bark_path)
            _voice_player.play()
    
    func _get_team_prefix(team: int) -> String:
        match team:
            1: return "red"
            2: return "blue"
            _: return "neutral"
    
    # Bark trigger points:
    # - Unit spawns: "spawn"
    # - Unit attacks: "attack"
    # - Unit dies: "death"
    # - Territory captured: "capture"
    # - Victory: "victory"
    ```
    
    2. Call barks from appropriate locations:
    - UnitBase.die() → "death" bark
    - Factory.complete_production() → "spawn" bark
    - TerritoryManager.capture_territory() → "capture" bark
  </action>
  <verify>Voice barks play occasionally</verify>
  <done>Voice bark system added</done>
</task>

<task type="auto">
  <name>Add background music</name>
  <files>scripts/core/audio_manager.gd, scripts/game/game_manager.gd</files>
  <action>
    Add background music system:
    
    1. AudioManager methods:
    ```gdscript
    func play_game_music() -> void:
        var tracks = [
            "res://assets/audio/music/action_loop.ogg",
            "res://assets/audio/music/battle_theme.ogg"
        ]
        var track = tracks[randi() % tracks.size()]
        play_music(track)
    
    func play_menu_music() -> void:
        play_music("res://assets/audio/music/menu_theme.ogg")
    
    func fade_out_music(duration: float = 1.0) -> void:
        var tween = create_tween()
        tween.tween_property(_music_player, "volume_db", -80, duration)
        tween.tween_callback(func(): _music_player.stop())
    ```
    
    2. Integrate with GameManager:
    ```gdscript
    # In GameManager._ready() or level start:
    AudioManager.play_game_music()
    
    # On game over:
    AudioManager.fade_out_music()
    ```
  </action>
  <verify>Background music plays during gameplay</verify>
  <done>Background music added</done>
</task>

<task type="auto">
  <name>Add damage smoke particles</name>
  <files>scripts/units/unit_base.gd</files>
  <action>
    Add smoke particles for damaged units:
    
    1. Add to UnitBase:
    ```gdscript
    var _smoke_timer: float = 0.0
    var _smoke_particles: CPUParticles2D

    func _ready() -> void:
        # ... existing code ...
        _setup_smoke_particles()

    func _setup_smoke_particles() -> void:
        _smoke_particles = CPUParticles2D.new()
        _smoke_particles.emitting = false
        _smoke_particles.amount = 3
        _smoke_particles.lifetime = 1.0
        _smoke_particles.direction = Vector2(0, -1)  # Rise up
        _smoke_particles.initial_velocity_min = 20
        _smoke_particles.initial_velocity_max = 40
        _smoke_particles.spread = 45
        _smoke_particles.color = Color(0.3, 0.3, 0.3, 0.5)  # Gray smoke
        add_child(_smoke_particles)

    func _process(delta: float) -> void:
        # ... existing code ...
        _update_damage_smoke(delta)

    func _update_damage_smoke(delta: float) -> void:
        var hp_percent = hp / max_hp
        if hp_percent < 0.5:  # Below 50% HP
            _smoke_timer += delta
            if _smoke_timer > 0.2:
                _smoke_timer = 0.0
                _smoke_particles.emitting = true
                # Stop when healed
        else:
            _smoke_particles.emitting = false
    ```
  </action>
  <verify>Damaged units emit smoke</verify>
  <done>Damage smoke particles added</done>
</task>

<task type="auto">
  <name>Add selection indicator effect</name>
  <files>scripts/game/selection_manager.gd</files>
  <action>
    Add visual feedback for unit selection:
    
    1. Modify SelectionManager:
    ```gdscript
    const SELECTION_RING_SCENE = preload("res://scenes/effects/selection_ring.tscn")

    func select_unit(unit: Node2D) -> void:
        selected_units.append(unit)
        
        # Spawn selection ring
        var ring = SELECTION_RING_SCENE.instantiate()
        ring.global_position = unit.global_position
        get_tree().current_scene.add_child(ring)
        
        # Track ring for cleanup
        _selection_rings[unit] = ring
        
        # Play selection sound
        AudioManager.play_sound("ui_select")

    func deselect_unit(unit: Node2D) -> void:
        selected_units.erase(unit)
        
        # Remove selection ring
        if _selection_rings.has(unit):
            _selection_rings[unit].queue_free()
            _selection_rings.erase(unit)
    ```
    
    2. Create selection_ring.tscn:
    ```
    - Node2D
      - Line2D (ring shape, dashed circle)
      - AnimationPlayer (pulse animation)
    ```
    
    3. Selection ring visual:
    - Color: Cyan for player, Red for enemy
    - Pulsing animation
    - Follows unit position
  </action>
  <verify>Selection rings appear when selecting units</verify>
  <done>Selection indicator added</done>
</task>

<task type="checkpoint:human-verify">
  <what-built>Audio manager, explosion effects, sounds, particles</what-built>
  <how-to-verify>
    1. Start game and verify background music plays
    2. Select units - verify selection sound and ring
    3. Order units to attack - verify gunfire sounds
    4. Watch units die - verify explosion and death sounds
    5. Check damaged units emit smoke at low HP
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

<verification>
- AudioManager singleton exists
- Explosion particle effect works
- Units make sound when firing
- Explosions produce sound
- Units emit smoke at low HP
- Selection indicators display
- Background music plays (if audio files exist)
</verification>

<success_criteria>
- Units make sound when firing
- Explosions produce sound and particles
- Units play voice barks when moving/attacking/dying
- Background music plays during gameplay
- Damage smoke particles visible at low HP
- Selection indicators visible
</success_criteria>

</tasks>
