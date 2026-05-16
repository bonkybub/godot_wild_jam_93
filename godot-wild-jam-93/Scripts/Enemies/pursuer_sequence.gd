class_name PursuerSequence
extends Path3D

@export var pursuer_fly_spd: float = 15.0
@export var pursuer_shoot_fly_spd: float = 3.0
@export var pursuer_enter_gap: float = 0.1
@export var pursuer_shoot_gap: float = 0.6
@export var shoot_x_bounds: Vector2 = Vector2(-5.0, 5.0)

var active_pursuers: Array[Pursuer]
var shooters: Array[Pursuer]

@export var y_bounds: Vector2 = Vector2(0.5, 2.5)

func setup_position() -> void:
	position.y = randf_range(y_bounds.x, y_bounds.y)

func start_pursuers() -> void:
	# start moving one at a time
	for pursuer in active_pursuers:
		pursuer.move_speed = pursuer_fly_spd
		await get_tree().create_timer(pursuer_enter_gap).timeout
	
	while !is_in_shoot_range():
		await get_tree().process_frame
	
	# slow down
	for pursuer in active_pursuers:
		pursuer.move_speed = pursuer_shoot_fly_spd
	
	# start shooting randomly
	shooters.clear()
	shooters = active_pursuers.duplicate()
	while is_in_shoot_range():
		var shooter: Pursuer = shooters.pick_random()
		shooters.remove_at(shooters.find(shooter))
		if shooter != null:
			shooter.set_fire_location(shooter.spawner.player.global_position)
			shooter.shoot()
		await get_tree().create_timer(pursuer_shoot_gap).timeout
	
	# return to original speed to leave
	for pursuer in active_pursuers:
		pursuer.move_speed = pursuer_fly_spd
	
	await active_pursuers.is_empty()

func is_in_shoot_range() -> bool:
	var x: float = get_group_position().x
	return (x >= shoot_x_bounds.x && x <= shoot_x_bounds.y) || (x <= shoot_x_bounds.x && x >= shoot_x_bounds.y)

func get_group_position() -> Vector3:
	var total_pos: Vector3 = Vector3.ZERO
	var total_count: int = active_pursuers.size()
	
	for pursuer in active_pursuers:
		total_pos += pursuer.global_position
	
	return total_pos / total_count
