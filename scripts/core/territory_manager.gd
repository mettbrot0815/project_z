extends Node

# Singleton Territory Manager for Z (1996)
# Handles flag capture, territory ownership, production multiplier

enum Owner { NEUTRAL, RED, BLUE }

signal territory_captured(territory_id: int, new_owner: Owner)
signal production_multiplier_updated(multiplier: float)

var territories: Dictionary = {}
var owned_territories: Dictionary = { Owner.RED: 0, Owner.BLUE: 0, Owner.NEUTRAL: 0 }
var production_multiplier: float = 1.0

# Original Z formula: speed = 1 + (0.15 * total_territories)
const MULTIPLIER_PER_TERRITORY: float = 0.15


func _ready() -> void:
	await get_tree().process_frame
	update_production_multiplier()


func register_territory(territory_id: int, flag_node: Node2D) -> void:
	territories[territory_id] = {
		"id": territory_id,
		"owner": Owner.NEUTRAL,
		"flag": flag_node,
		"factories": [],
		"buildings": []
	}
	
	owned_territories[Owner.NEUTRAL] += 1
	
	# Connect to Area2D's body_entered signal (flag has an Area2D child)
	var flag_area = flag_node.get_node_or_null("Area2D")
	if flag_area and flag_area.has_signal("body_entered"):
		flag_area.body_entered.connect(func(body): _on_flag_overlap(territory_id, body))


func capture_territory(territory_id: int, new_owner: Owner) -> void:
	if not territories.has(territory_id):
		return
	
	var territory = territories[territory_id]
	var old_owner = territory.owner
	
	if old_owner == new_owner:
		return
	
	# Update counts
	owned_territories[old_owner] -= 1
	owned_territories[new_owner] += 1
	territory.owner = new_owner
	
	# Update global multiplier
	update_production_multiplier()
	
	territory_captured.emit(territory_id, new_owner)


func update_production_multiplier() -> void:
	# Production speed scales with total territories controlled
	var total_owned = owned_territories[Owner.RED] + owned_territories[Owner.BLUE]
	production_multiplier = 1.0 + (MULTIPLIER_PER_TERRITORY * total_owned)
	production_multiplier_updated.emit(production_multiplier)


func get_production_speed_for_owner(team_owner: Owner) -> float:
	# Production speed = base_time / (1 + 0.15 * territories_owned)
	return 1.0 + (MULTIPLIER_PER_TERRITORY * owned_territories[team_owner])


func _on_flag_overlap(territory_id: int, body: Node2D) -> void:
	if body.has_method("get_team_id"):
		var unit_owner = body.get_team_id()
		if unit_owner in [Owner.RED, Owner.BLUE]:
			capture_territory(territory_id, unit_owner)


func get_territory_count(team_owner: Owner) -> int:
	return owned_territories[team_owner]

