class_name SpriteManager
extends Node

# Centralized sprite path resolution for Z (1996) assets
# Maps Godot Team enum to original Z sprite colors

# Base path to copied Z (1996) sprite assets
const ASSET_BASE_PATH = "res://assets/sprites/"

# Maps Godot Team enum to zod_engine sprite color names
static func team_to_color(team: int) -> String:
	match team:
		UnitBase.Team.RED: return "red"    # Player
		UnitBase.Team.BLUE: return "blue"   # AI opponent
		UnitBase.Team.NEUTRAL: return "green"  # Neutral/unclaimed
		_: return "green"


# Get sprite frame path for robots
# unit_type: grunt, psycho, tough, sniper, laser, commander, pyro
# team: Godot Team enum value
# action: walk, fire, die1, die2, etc.
# direction: r000, r045, r090, etc. (default r000 = facing right)
# frame: animation frame n00, n01, etc. (default n00)
#
# NOTE: Walk animation is in root robots/ folder: walk_{team}_{direction}_{frame}.png
# Fire/death animations are in unit subfolders: {unit_type}/fire_{team}_{direction}_{frame}.png
static func get_robot_sprite(unit_type: String, team: int, 
							 action: String = "walk",
							 direction: String = "r000",
							 frame: String = "n00") -> String:
	var color = team_to_color(team)
	
	if action == "walk":
		# Walk is shared across all robots in root folder
		return ASSET_BASE_PATH + "units/robots/walk_%s_%s_%s.png" % [color, direction, frame]
	else:
		# Fire and death animations are unit-specific
		return ASSET_BASE_PATH + "units/robots/%s/%s_%s_%s_%s.png" % [unit_type, action, color, direction, frame]


# Get sprite frame path for vehicles
# unit_type: jeep, light, medium, heavy, apc, crane, missile_launcher
# team: Godot Team enum value
# state: base, base_damaged
# direction: r000, r045, r090, etc.
# frame: animation frame n00, n01, etc.
static func get_vehicle_sprite(unit_type: String, team: int,
								state: String = "base",
								direction: String = "r000",
								frame: String = "n00") -> String:
	var color = team_to_color(team)
	return ASSET_BASE_PATH + "units/vehicles/%s/%s_%s_%s_%s.png" % [unit_type, state, color, direction, frame]


# Get sprite path for cannons (stationary guns)
# unit_type: gatling, howitzer
# team: Godot Team enum value
# action: fire, idle, etc.
static func get_cannon_sprite(unit_type: String, team: int,
							   action: String = "base") -> String:
	var color = team_to_color(team)
	return ASSET_BASE_PATH + "units/cannons/%s/%s_%s.png" % [unit_type, action, color]


# Get building sprite path
# building_type: robot, vehicle, fort, radar, repair
# team: Godot Team enum value
# state: normal, damaged, destroyed
static func get_building_sprite(building_type: String, team: int,
								 state: String = "normal") -> String:
	var color = team_to_color(team)
	return ASSET_BASE_PATH + "buildings/%s/%s_%s.png" % [building_type, color, state]


# Get flag sprite for territory
# team: Godot Team enum value
static func get_flag_sprite(team: int) -> String:
	var color = team_to_color(team)
	return ASSET_BASE_PATH + "buildings/flag_%s.png" % color


# Load a sprite texture, returns null if not found
static func load_sprite_texture(path: String) -> Texture2D:
	var full_path = "res://" + path
	if ResourceLoader.exists(full_path):
		return load(full_path)
	return null


# Create AnimatedSprite2D with walk animation for a robot unit
static func create_robot_sprite(unit_type: String, team: int) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.name = "UnitSprite"
	
	var frames = SpriteFrames.new()
	var color = team_to_color(team)
	
	# Walk animation: walk_{color}_r000_n{00-03}.png (in root robots folder)
	frames.add_animation("walk")
	var walk_base = ASSET_BASE_PATH + "robots/walk_%s_r000_n%%02d.png" % color
	for i in range(4):
		var full_path = walk_base % i
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("walk", texture)
	
	# Fire animation: {unit_type}/fire_{color}_r000_n{00-04}.png (in unit subfolder)
	frames.add_animation("fire")
	for i in range(5):
		var full_path = ASSET_BASE_PATH + "robots/%s/fire_%s_r000_n%02d.png" % [unit_type, color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("fire", texture)
	
	# Fallback: if no frames loaded, create a placeholder
	if frames.get_frame_count("walk") == 0:
		# Use a simple colored rectangle as placeholder
		var placeholder = create_placeholder_texture(Color(1, 0, 0))  # Red
		frames.add_frame("walk", placeholder)
	
	sprite.sprite_frames = frames
	sprite.animation = "walk"
	sprite.playing = true
	sprite.centered = true
	sprite.offset = Vector2(0, 0)
	
	return sprite


# Create a simple colored placeholder texture
static func create_placeholder_texture(color: Color) -> ImageTexture:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	return texture


# Create AnimatedSprite2D with base/damaged animations for a vehicle
static func create_vehicle_sprite(unit_type: String, team: int) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.name = "UnitSprite"
	
	var frames = SpriteFrames.new()
	var color = team_to_color(team)
	var base_path = ASSET_BASE_PATH + "vehicles/%s/" % unit_type
	
	# Base animation: base_{color}_r000_n{00-02}.png
	frames.add_animation("base")
	for i in range(3):
		var full_path = base_path + "base_%s_r000_n%02d.png" % [color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("base", texture)
	
	# Damaged animation: base_damaged_{color}_r000_n{00-02}.png
	frames.add_animation("damaged")
	for i in range(3):
		var full_path = base_path + "base_damaged_%s_r000_n%02d.png" % [color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("damaged", texture)
	
	# Fallback: if no frames loaded, create a placeholder
	if frames.get_frame_count("base") == 0:
		var placeholder = create_placeholder_texture(Color(0, 0, 1))  # Blue
		frames.add_frame("base", placeholder)
	
	sprite.sprite_frames = frames
	sprite.animation = "base"
	sprite.playing = true
	sprite.centered = true
	sprite.offset = Vector2(0, 0)
	
	return sprite


# Get direction string from angle (for 8-directional sprites)
static func angle_to_direction(angle: float) -> String:
	# Normalize angle to 0-360
	var normalized = fmod(angle, 360.0)
	if normalized < 0:
		normalized += 360.0
	
	# Map to 8 directions
	if normalized >= 337.5 or normalized < 22.5:
		return "r000"   # Right
	elif normalized >= 22.5 and normalized < 67.5:
		return "r045"   # Down-Right
	elif normalized >= 67.5 and normalized < 112.5:
		return "r090"   # Down
	elif normalized >= 112.5 and normalized < 157.5:
		return "r135"   # Down-Left
	elif normalized >= 157.5 and normalized < 202.5:
		return "r180"   # Left
	elif normalized >= 202.5 and normalized < 247.5:
		return "r225"   # Up-Left
	elif normalized >= 247.5 and normalized < 292.5:
		return "r270"   # Up
	elif normalized >= 292.5 and normalized < 337.5:
		return "r315"   # Up-Right
	
	return "r000"  # Default


# Get animation speed based on original Z tick rate
# Original Z used ~10 ticks per second
static func get_animation_speed() -> float:
	return 10.0  # 10 FPS
