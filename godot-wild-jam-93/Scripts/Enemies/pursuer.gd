class_name Pursuer
extends Enemy

var sequence: PursuerSequence

@export var left_fire_location: Node3D
@export var right_fire_location: Node3D

var already_fired: bool = false

func shoot() -> void:
	already_fired = true
	super()

func set_fire_location(target_pos: Vector3) -> void:
	var left_dist = left_fire_location.global_position.distance_to(target_pos)
	var right_dist = right_fire_location.global_position.distance_to(target_pos)
	fire_locations.clear()
	if left_dist < right_dist:
		fire_locations.push_back(left_fire_location)
	else:
		fire_locations.push_back(right_fire_location)

func death() -> void:
	if sequence != null && sequence.active_pursuers.has(self):
		sequence.active_pursuers.remove_at(sequence.active_pursuers.find(self))
	if sequence != null && sequence.shoot_count > 0 && !already_fired:
		sequence.planned_shooters -= 1
	super()
	
	GameManager.player_money += 75
