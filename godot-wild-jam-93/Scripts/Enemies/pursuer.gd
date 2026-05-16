class_name Pursuer
extends Enemy

var sequence: PursuerSequence

@export var left_fire_location: Node3D
@export var right_fire_location: Node3D

func set_fire_location(target_pos: Vector3) -> void:
	var left_dist = left_fire_location.global_position.distance_to(target_pos)
	var right_dist = right_fire_location.global_position.distance_to(target_pos)
	fire_locations.clear()
	if left_dist < right_dist:
		fire_locations.push_back(left_fire_location)
	else:
		fire_locations.push_back(right_fire_location)

func death() -> void:
	if sequence.active_pursuers.has(self):
		sequence.active_pursuers.remove_at(sequence.active_pursuers.find(self))
	super()
