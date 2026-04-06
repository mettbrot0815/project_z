extends Node2D

# Fort - main base, victory condition when destroyed

@export var max_hp: float = 1000
@export var team_owner: int = 0

var hp: float = 1000.0
var corner_turrets: Array = []

signal destroyed(by_owner: int)
signal damaged(amount: float, attacker: Node2D)

var _sprite: Sprite2D


func _ready() -> void:
	add_to_group("fort")
	add_to_group("building")
	hp = max_hp
	
	_sprite = $Sprite2D
	_update_sprite()
	
	# Create corner turrets
	for i in range(4):
		var turret_angle = i * PI/2
		var turret_pos = Vector2(cos(turret_angle), sin(turret_angle)) * 120
		
		var turret_scene = load("res://scenes/units/gatling.tscn")
		if turret_scene:
			var turret = turret_scene.instantiate()
			turret.global_position = global_position + turret_pos
			turret.team_id = team_owner
			turret.team = team_owner
			get_parent().add_child(turret)
			corner_turrets.append(turret)


func _update_sprite() -> void:
	if not _sprite:
		return
	
	var sprite_path = "res://assets/sprites/buildings/fort/fort_arctic_front.png"
	if ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path)
	else:
		_sprite.texture = _create_placeholder()


func _create_placeholder() -> ImageTexture:
	var image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.2, 0.2))
	return ImageTexture.create_from_image(image)


func take_damage(amount: float, attacker: Node2D) -> void:
	hp -= amount
	damaged.emit(amount, attacker)
	
	if hp <= 0:
		destroy(attacker)


func destroy(attacker: Node2D) -> void:
	CombatManager.apply_splash_damage(global_position, 300, 200, attacker)
	
	for turret in corner_turrets:
		if turret and turret.hp > 0:
			turret.take_damage(9999, attacker)
	
	destroyed.emit(attacker.get_team() if attacker.has_method("get_team") else 0)
	queue_free()


func get_team_id() -> int:
	return team_owner


func get_hp_percentage() -> float:
	return hp / max_hp


func can_enter(unit: Node2D) -> bool:
	return unit.team != team_owner

