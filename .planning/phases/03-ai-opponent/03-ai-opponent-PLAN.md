---
phase: 03-ai-opponent
plan: 01
type: execute
wave: 1
depends_on:
  - "02-visual-assets"
files_modified:
  - scripts/core/game_state.gd
  - scripts/game/game_manager.gd
  - scripts/campaign/level_loader.gd
must_haves:
  truths:
    - "AI opponent can be selected in game setup"
    - "AI captures flags and expands territory"
    - "AI produces units appropriate to owned territories"
    - "AI attacks player base with appropriate force"
    - "AI difficulty feels distinct (Easy=passive, Hard=aggressive)"
  artifacts:
    - path: "scripts/game/ai_controller.gd"
      provides: "Centralized AI state machine and production logic"
      exports: ["AIState enum", "difficulty", "production_queue", "evaluate_state()"]
    - path: "scripts/game/ai_behavior.gd"
      provides: "AI unit-level behavior override"
      exports: ["get_target_priority()", "should_attack()", "should_capture()"]
---

<objective>
Implement computer AI opponent with state machine, difficulty levels, and production strategy.

Purpose: Make game playable against AI, enable full campaign testing.

Output: AI controller singleton, behavior scripts, game setup integration.
</objective>

<execution_context>
@C:/Users/Philipp/.config/opencode/get-shit-done/workflows/execute-plan.md
@C:/Users/Philipp/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/CODE_MAP.md
@.planning/ROADMAP.md
@.planning/research/ARCHITECTURE.md

# AI Architecture Context

## Current Unit Intelligence System
Units have `intelligence: int = 0` property (0-5 scale):
- 0: Rush flags, no tactical awareness (grunts, howitzers, gatlings)
- 1: Basic combat, target nearby enemies (psychos)
- 2: Vehicle priority, basic tactics (tough, jeeps, APCs)
- 3: Target selection, splash awareness (snipers, tanks, cranes)
- 4: Threat avoidance, strategic movement (lasers)
- 5: Full strategic AI (commanders)

## Territory System
- `TerritoryManager.get_territory_count(team)` returns owned territory count
- Flags have `team_owner` property
- Production speed = 1.0 + (0.15 × territories_owned)

## Existing Unit Behaviors
All units use `UnitBase._process()` with intelligence-based AI:
- Rushing: Move toward nearest enemy flag
- Combat: `find_nearest_enemy()`, `find_enemy_groups()`
- Retreat: Commander only - retreats when outnumbered

## Factory System
- `Factory.start_production(unit_type)` queues unit
- `Factory.get_build_percentage()` for progress
- `TerritoryManager.update_production_multiplier()` affects speed

## Blue Team (AI) Setup
- BLUE = 2 in Team enum
- Level loader sets `team_id = 2` for AI units
- Fort at fixed position per level

</context>

<tasks>

<task type="manual">
  <name>Create AI controller singleton</name>
  <files>scripts/game/ai_controller.gd</files>
  <action>
    Create centralized AI controller as an autoload singleton:
    
    1. Add to project.godot autoloads as `AIController`
    
    2. Define AIState enum:
    ```gdscript
    enum AIState {
        IDLE,       # No units, waiting for production
        EXPAND,     # Capture nearby unclaimed territories
        ATTACK,     # Push toward enemy base
        DEFEND,     # Protect key territories
        REINFORCE   # Rebuild after losses
    }
    ```
    
    3. Define Difficulty enum:
    ```gdscript
    enum Difficulty {
        EASY,       # Slow production, passive
        NORMAL,     # Balanced
        HARD        # Fast production, aggressive
    }
    ```
    
    4. Key properties:
    ```gdscript
    var difficulty: Difficulty = Difficulty.NORMAL
    var current_state: AIState = AIState.IDLE
    var target_territory: Vector2i = Vector2i.ZERO
    var attack_force_threshold: int = 5
    ```
    
    5. Key methods:
    - `evaluate_state()` - Decide AI state based on game conditions
    - `execute_state()` - Perform actions for current state
    - `update()` - Called every ~1 second (not every frame)
    - `set_difficulty(d: Difficulty)` - Configure AI behavior
  </action>
  <verify>AI controller exists and can be configured</verify>
  <done>AI controller singleton created with state machine</done>
</task>

<task type="auto">
  <name>Implement AI state evaluation logic</name>
  <files>scripts/game/ai_controller.gd</files>
  <action>
    Implement `evaluate_state()` logic:
    
    State transition rules:
    
    ```
    IDLE → EXPAND:
        When: production_queue empty AND territories < 3
        Transition: Find nearest unclaimed flag
    
    IDLE → ATTACK:
        When: production_queue empty AND territories >= 3 AND unit_count >= 5
        Transition: Set target to enemy fort position
    
    EXPAND → ATTACK:
        When: territories >= 3 AND unit_count >= attack_force_threshold
        Transition: Set target to enemy base
    
    EXPAND → DEFEND:
        When: enemy units near owned territory AND unit_count < 3
        Transition: Set rally point at threatened territory
    
    ATTACK → REINFORCE:
        When: unit_count < 3 AND enemy near attack target
        Transition: Stop attack, wait for production
    
    Any → IDLE:
        When: production in progress
        Transition: Wait for units
    ```
    
    Decision factors:
    - `TerritoryManager.get_territory_count(Team.BLUE)`
    - Count of BLUE units in scene
    - Count of RED units near BLUE territories
    - Distance to enemy fort
  </action>
  <verify>AI state changes correctly based on game conditions</verify>
  <done>State evaluation logic implemented</done>
</task>

<task type="auto">
  <name>Implement AI production logic</name>
  <files>scripts/game/ai_controller.gd</files>
  <action>
    Implement `execute_production()` method:
    
    1. Find AI factory references:
    ```gdscript
    var factories = get_tree().get_nodes_in_group("factory").filter(func(f):
        return f.team == Team.BLUE
    )
    ```
    
    2. Production queue by difficulty:
    
    EASY:
    - 70% grunts (fodder)
    - 20% tough (tank)
    - 10% psycho (support)
    
    NORMAL:
    - 40% grunts
    - 25% tough
    - 15% psycho
    - 10% sniper (anti-vehicle)
    - 10% light_tank
    
    HARD:
    - 30% grunts
    - 20% tough
    - 15% medium_tank
    - 15% sniper
    - 10% laser (anti-cluster)
    - 10% heavy_tank
    
    3. Production timing:
    - EASY: 1.5x normal build time
    - NORMAL: 1.0x normal build time
    - HARD: 0.7x normal build time (via production multiplier)
    
    4. Queue management:
    - Check if factory is producing
    - If idle, start next unit from queue
    - Prioritize based on state (DEFEND → more toughs)
  </action>
  <verify>AI produces appropriate unit mix for difficulty</verify>
  <done>Production logic implemented</done>
</task>

<task type="auto">
  <name>Implement AI unit command system</name>
  <files>scripts/game/ai_controller.gd</files>
  <action>
    Implement unit command system:
    
    1. Find all AI units:
    ```gdscript
    var units = get_tree().get_nodes_in_group("selectable").filter(func(u):
        return u.team == Team.BLUE and u.has_method("move_to")
    )
    ```
    
    2. Command modes by state:
    
    IDLE: No commands (let units use default AI)
    
    EXPAND:
    - All units move toward unclaimed flag
    - Override default AI temporarily
    - Once captured, switch to ATTACK
    
    ATTACK:
    - Group units into squads
    - 70% attack force: Move toward enemy fort
    - 30% defensive: Follow main force
    - Use `move_to()` on UnitBase
    
    DEFEND:
    - All units return to threatened territory
    - Prioritize protecting factories
    
    REINFORCE:
    - Units hold position
    - Wait for production before attacking
    
    3. Command batching:
    - Issue commands in batches of 5 units
    - 0.5s delay between batches to prevent lag
  </action>
  <verify>AI units respond to controller commands</verify>
  <done>Unit command system implemented</done>
</task>

<task type="auto">
  <name>Add AI to game setup/level loader</name>
  <files>scripts/game/game_manager.gd, scripts/campaign/level_loader.gd</files>
  <action>
    Integrate AI into game flow:
    
    1. Level loader modification:
    ```gdscript
    # After loading level, check if AI opponent enabled
    if GameState.ai_enabled:
        AIController.initialize()
        AIController.set_difficulty(GameState.ai_difficulty)
    ```
    
    2. GameState modifications:
    ```gdscript
    var ai_enabled: bool = false
    var ai_difficulty: AIController.Difficulty = AIController.Difficulty.NORMAL
    ```
    
    3. Command line / test mode:
    - For headless testing, enable AI automatically
    - `AIController.enable_for_testing()`
    
    4. Cleanup on level end:
    ```gdscript
    func _notification(what: int) -> void:
        if what == Node.NOTIFICATION_EXIT_TREE:
            AIController.cleanup()
    ```
  </action>
  <verify>AI initializes correctly when level loads</verify>
  <done>AI integrated into game flow</done>
</task>

<task type="auto">
  <name>Add AI unit behavior enhancement</name>
  <files>scripts/units/unit_base.gd</files>
  <action>
    Enhance unit AI when under AI control:
    
    1. Add AI controller reference to UnitBase:
    ```gdscript
    var ai_controller: Node = null  # Set by AIController
    ```
    
    2. Add AI-aware behavior methods:
    ```gdscript
    func ai_get_target() -> Node2D:
        if ai_controller:
            return ai_controller.get_current_target()
        return find_nearest_enemy()
    
    func ai_should_regroup() -> bool:
        if ai_controller:
            return ai_controller.current_state == AIController.AIState.DEFEND
        return false
    ```
    
    3. Modify _process to respect AI commands:
    - If `ai_controller != null`, check for commanded actions
    - Otherwise, use default intelligence-based AI
    
    4. Fleeing behavior for AI units:
    ```gdscript
    func ai_consider_fleeing() -> bool:
        if ai_controller and ai_controller.difficulty == AIController.Difficulty.EASY:
            # Easy AI units flee at 30% HP
            return hp < max_hp * 0.3
        return false
    ```
  </action>
  <verify>Units behave differently under AI control</verify>
  <done>AI unit behavior enhanced</done>
</task>

<task type="auto">
  <name>Add difficulty-specific behaviors</name>
  <files>scripts/game/ai_controller.gd</files>
  <action>
    Implement difficulty-specific behaviors:
    
    EASY:
    - 1.5x build time
    - Units flee at 30% HP
    - 5+ unit advantage before attacking
    - 10 second delay before first attack
    - Does not target enemy factories
    
    NORMAL:
    - 1.0x build time (default)
    - Units fight to 10% HP
    - 3+ unit advantage before attacking
    - 5 second delay before first attack
    - Targets enemy factories occasionally
    
    HARD:
    - 0.7x build time
    - Units fight to 5% HP
    - Any units before attacking
    - No delay before first attack
    - Prioritizes destroying factories
    - Micro-manages unit positioning
    
    Implementation:
    ```gdscript
    func get_attack_threshold() -> int:
        match difficulty:
            Difficulty.EASY: return 5
            Difficulty.NORMAL: return 3
            Difficulty.HARD: return 1
    
    func get_flee_threshold() -> float:
        match difficulty:
            Difficulty.EASY: return 0.3
            Difficulty.NORMAL: return 0.1
            Difficulty.HARD: return 0.05
    
    func should_target_factory() -> bool:
        match difficulty:
            Difficulty.EASY: return false
            Difficulty.NORMAL: return randf() < 0.2
            Difficulty.HARD: return true
    ```
  </action>
  <verify>Difficulty levels feel distinct when playing</verify>
  <done>Difficulty-specific behaviors implemented</done>
</task>

<task type="auto">
  <name>Add AI information gathering (vision)</name>
  <files>scripts/game/ai_controller.gd</files>
  <action>
    Implement AI "vision" system (not cheating):
    
    1. Vision range based on unit types:
    ```gdscript
    func get_vision_range(unit: Node2D) -> float:
        match unit.unit_type:
            "sniper": return 500.0
            "commander": return 400.0
            "howitzer": return 600.0
            _: return 300.0
    ```
    
    2. Known enemy tracking:
    ```gdscript
    var known_enemies: Array[Dictionary] = []  # [{unit, last_seen, position}]
    var vision_timer: float = 0.0
    
    func update_vision() -> void:
        vision_timer += delta
        if vision_timer < 0.5:  # Update every 0.5s
            return
        vision_timer = 0.0
        
        for unit in get_ai_units():
            var enemies = find_enemies_in_vision(unit)
            for enemy in enemies:
                update_known_enemy(enemy)
        
        # Remove stale entries (enemy not seen for 10s)
        known_enemies = known_enemies.filter(func(e):
            return e.last_seen > -10.0
        )
    ```
    
    3. Use known enemies for targeting:
    - Attack the weakest known enemy
    - Prioritize low-HP targets
    - Avoid attacking into bad odds
    
    4. Map awareness:
    ```gdscript
    var explored_territories: Array[Vector2i] = []
    
    func update_map_awareness() -> void:
        for flag in get_tree().get_nodes_in_group("flag"):
            if flag.global_position.distance_to(get_ai_center()) < 1000:
                if not explored_territories.has(flag.territory_id):
                    explored_territories.append(flag.territory_id)
    ```
  </action>
  <verify>AI makes informed decisions, not omniscient</verify>
  <done>Vision system implemented</done>
</task>

<task type="checkpoint:human-verify">
  <what-built>AI opponent with state machine and difficulty levels</what-built>
  <how-to-verify>
    1. Start level 1 with EASY AI
    2. Verify AI produces units
    3. Watch AI capture flags
    4. Test NORMAL difficulty - AI should be more aggressive
    5. Test HARD difficulty - AI should be relentless
    6. Verify AI eventually attacks player base
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

<verification>
- AIController singleton exists and initializes
- AI states (IDLE, EXPAND, ATTACK, DEFEND, REINFORCE) implemented
- Difficulty levels (EASY, NORMAL, HARD) feel distinct
- AI produces appropriate unit mix for difficulty
- AI captures flags and expands territory
- AI attacks player base with appropriate force
- No omniscient cheating - AI uses vision system
</verification>

<success_criteria>
- Player can select AI opponent in game setup
- AI captures flags and expands territory
- AI produces units appropriate to owned territories
- AI attacks player with appropriate force
- AI difficulty feels distinct (Easy = passive, Hard = aggressive)
- Game is playable start to finish against AI
</success_criteria>

</tasks>
