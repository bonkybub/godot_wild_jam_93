class_name Pursuer
extends Enemy

var sequence: PursuerSequence

@export var left_fire_location: Node3D
@export var right_fire_location: Node3D
@export var speed_change_dur: float = 0.5

var move_speed: float = 0.0:
	set(value):
		var timer: float = 0.0
		var delta: float = get_process_delta_time()
		var start_value: float = move_speed
		
		var tree := get_tree()
		if tree == null:
			return
		
		while is_inside_tree() && timer < speed_change_dur:
			move_speed = lerp(start_value, value, timer / speed_change_dur)
			timer += delta
			await tree.process_frame
		move_speed = value

func shoot(_b_obj: PackedScene = bullet_obj, _dmg: int = shot_dmg) -> void:
	super()

func begin_fly_in(path: PathFollow3D) -> void:
	var delta: float = get_physics_process_delta_time()
	
	var tree := get_tree()
	if tree == null:
		return
	
	while is_inside_tree() && path.progress_ratio < 1.0:
		path.progress += move_speed * delta
		await tree.process_frame
	
	if sequence.active_pursuers.has(self):
		sequence.active_pursuers.remove_at(sequence.active_pursuers.find(self))
	
	path.queue_free()
	queue_free()

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
	if sequence != null && sequence.shooters.has(self):
		sequence.shooters.remove_at(sequence.shooters.find(self))
	super()
	
	GameManager.player_money += 75
