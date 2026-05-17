class_name PursuerSequence
extends Path3D

@export var pursuer_fly_spd: float = 15.0
@export var pursuer_shoot_fly_spd: float = 3.0
@export var pursuer_enter_gap: float = 0.2
@export var pursuer_shoot_gap: float = 0.6
@export var shoot_x_bounds: Vector2 = Vector2(-5.0, 5.0)

var active_pursuers: Array[Pursuer]
var shooters: Array[Pursuer]

@export var y_bounds: Vector2 = Vector2(0.5, 2.5)

func setup_position() -> void:
	position.y = randf_range(y_bounds.x, y_bounds.y)

func start_pursuers() -> void: # Getting a array error, so Im putting every check under the sun because I cant tell where its happening
	clean_pursuer_arrays()

	# start moving one at a time
	for pursuer in active_pursuers:
		if is_instance_valid(pursuer) == false:
			continue

		pursuer.move_speed = pursuer_fly_spd
		await get_tree().create_timer(pursuer_enter_gap).timeout
	
	while !is_in_shoot_range():
		clean_pursuer_arrays()

		if active_pursuers.is_empty():
			return

		await get_tree().process_frame
	
	# slow down
	clean_pursuer_arrays()

	for pursuer in active_pursuers:
		if is_instance_valid(pursuer) == false:
			continue

		pursuer.move_speed = pursuer_shoot_fly_spd
	
	# start shooting randomly
	shooters.clear()
	shooters = active_pursuers.duplicate()
	clean_pursuer_arrays()

	while is_in_shoot_range():
		clean_pursuer_arrays()

		if shooters.is_empty():
			break

		var shooter: Pursuer = shooters.pick_random()
		shooters.remove_at(shooters.find(shooter))

		if is_instance_valid(shooter) == false:
			continue

		if shooter.spawner != null && shooter.spawner.player != null:
			shooter.set_fire_location(shooter.spawner.player.global_position)
			shooter.shoot()

		await get_tree().create_timer(pursuer_shoot_gap).timeout
	
	# return to original speed to leave
	clean_pursuer_arrays()

	for pursuer in active_pursuers:
		if is_instance_valid(pursuer) == false:
			continue

		pursuer.move_speed = pursuer_fly_spd

func clean_pursuer_arrays() -> void:
	for i in range(active_pursuers.size() - 1, -1, -1):
		if is_instance_valid(active_pursuers[i]) == false:
			active_pursuers.remove_at(i)

	for i in range(shooters.size() - 1, -1, -1):
		if is_instance_valid(shooters[i]) == false:
			shooters.remove_at(i)

func is_in_shoot_range() -> bool:
	var x: float = get_group_position().x
	return (x >= shoot_x_bounds.x && x <= shoot_x_bounds.y) || (x <= shoot_x_bounds.x && x >= shoot_x_bounds.y)

func get_group_position() -> Vector3:
	clean_pursuer_arrays()

	if active_pursuers.is_empty():
		return global_position

	var total_pos: Vector3 = Vector3.ZERO
	var total_count: int = active_pursuers.size()
	
	for pursuer in active_pursuers:
		total_pos += pursuer.global_position
	
	return total_pos / total_count
