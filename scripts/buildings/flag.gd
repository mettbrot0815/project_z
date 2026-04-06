extends StaticBody2D

# Flag node - captures territories when touched by friendly units

@export var territory_id: int = 0
var team_owner: int = 0  # 0=NEUTRAL, 1=RED, 2=BLUE

signal captured(new_owner: int)


func _ready() -> void:
	add_to_group("flag")
	var area = $Area2D
	if area:
		area.body_entered.connect(_on_body_entered)


func get_team_id() -> int:
	return team_owner


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_team_id"):
		var unit_owner = body.get_team_id()
		if unit_owner in [TerritoryManager.Owner.RED, TerritoryManager.Owner.BLUE]:
			if team_owner != unit_owner:
				capture(unit_owner)


func capture(new_owner: int) -> void:
	team_owner = new_owner
	captured.emit(new_owner)
