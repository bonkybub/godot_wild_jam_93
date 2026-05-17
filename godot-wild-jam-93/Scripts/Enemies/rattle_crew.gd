class_name RattleCrew
extends Bounty

@onready var paths: Node3D = $Paths
@onready var laser: Area3D = $Laser
@onready var laser_collider: CollisionShape3D = $"Laser/Laser Hitbox Collider"

@export_category("Movement")
@export var centre_point: Node3D
@export var enter_path: PathFollow3D
@export var exit_path: PathFollow3D
@export var fly_paths: Array[PathFollow3D]
@export var start_y_pos: float = 40.0
@export var base_z_pos: float = -15.0
@export var strafe_spd: float = 3.0
@export var fly_spd: float = 25.0
@export var fly_start_wait: float = 2.0
@export var fly_mid_wait: float = 1.0
@export var fly_end_wait: float = 3.0

@export_category("Strafing")
@export var strafe_points: Array[Node3D]
var cur_strafe_point: int = 0
@export var strafe_shot_obj: PackedScene
@export var strafe_shot_dmg: int = 10
@export var strafe_shot_num: int = 3
@export var strafe_shot_gap: float = 0.3
@export var strafe_move_num: int = 4
@export var strafe_move_gap: float = 2.0

@export_category("Charging")
@export var charge_point: Node3D
@export var charge_shot_obj: PackedScene
@export var charge_shot_dmg: int = 20
@export var charge_shot_num: int = 4
@export var charge_shot_gap: float = 1.2
@export var charge_up_time: float = 3.0
@export var charge_blink_colour: Color = Color.YELLOW
@export var charge_blink_num: int = 3

@export_category("Lasering")
@export var laser_point_1: Node3D
@export var laser_point_2: Node3D
@export var laser_heights: Array[float] = [4.0, 0.0, -4.0]
@export var laser_spd: float = 20.0
@export var laser_dmg: int = 25
@export var laser_start_wait: float = 3.0
@export var laser_mid_wait: float = 1.0
@export var laser_end_wait: float = 3.0

func spawn() -> void:
	position.z = base_z_pos
	remove_child(paths)
	spawner.add_child(paths)
	paths.position.z = base_z_pos
	position.y = start_y_pos
	laser.visible = false
	laser_collider.disabled = true
	await fly_out(false)

#region Path Movement
func to_centre() -> void:
	# move to centre
	var timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var to_centre_dur: float = abs(global_position.distance_to(centre_point.global_position)) / strafe_spd
	
	while timer < to_centre_dur:
		global_position = lerp(global_position, centre_point.global_position, timer / to_centre_dur)
		global_rotation.y = lerp(global_rotation.y, centre_point.global_rotation.y, timer / to_centre_dur)
		timer += delta
		await get_tree().process_frame
	
	cur_strafe_point = 0

func enter_screen() -> void:
	var delta: float = get_physics_process_delta_time()
	
	# child to exit path
	get_parent_node_3d().remove_child(self)
	enter_path.add_child(self)
	position = Vector3.ZERO
	enter_path.progress_ratio = 0.0
	rotation_degrees.y = 180
	
	# move along exit path
	while enter_path.progress_ratio < 1.0:
		enter_path.progress += fly_spd * delta
		await get_tree().process_frame
	
	var cur_pos: Vector3 = global_position
	enter_path.remove_child(self)
	spawner.add_child(self)
	global_position = cur_pos
	rotation_degrees.y = 0
	
	await to_centre()

func exit_screen() -> void:
	await to_centre()
	
	var delta: float = get_physics_process_delta_time()
	
	# child to exit path
	get_parent_node_3d().remove_child(self)
	exit_path.add_child(self)
	position = Vector3.ZERO
	exit_path.progress_ratio = 0.0
	rotation_degrees.y = 180
	
	# move along exit path
	while exit_path.progress_ratio < 1.0:
		exit_path.progress += fly_spd * delta
		await get_tree().process_frame
	
	var cur_pos: Vector3 = global_position
	exit_path.remove_child(self)
	spawner.add_child(self)
	global_position = cur_pos
	rotation_degrees.y = 0

func fly_out(exit: bool = true) -> void:
	if exit:
		await exit_screen()
	
	rotation_degrees.y = 180
	
	var delta: float = get_physics_process_delta_time()
	await get_tree().create_timer(fly_start_wait).timeout
	position = Vector3.ZERO
	
	var randomized_paths: Array[PathFollow3D] = fly_paths.duplicate()
	while !randomized_paths.is_empty():
		var path: PathFollow3D = randomized_paths.pick_random()
		randomized_paths.remove_at(randomized_paths.find(path))
		get_parent_node_3d().remove_child(self)
		path.add_child(self)
		path.progress_ratio = 0.0
		rotation_degrees.y = 180
		
		# move along path
		while path.progress_ratio < 1.0:
			path.progress += fly_spd * delta
			await get_tree().process_frame
		
		await get_tree().create_timer(fly_mid_wait).timeout
	
	await enter_screen()
#endregion

#region Strafe Shooting
func strafe_state() -> void:
	for i in strafe_move_num:
		triple_shot()
		await to_strafe_point()
		triple_shot()
		await get_tree().create_timer(strafe_move_gap).timeout

func to_strafe_point() -> void:
	var new_point: int = randi_range(0, strafe_points.size() - 1)
	
	while new_point == cur_strafe_point:
		new_point = randi_range(0, strafe_points.size() - 1)
	
	# move to new strafe point
	var timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var to_point_dur: float = abs(global_position.distance_to(strafe_points[new_point].global_position)) / strafe_spd
	
	while timer < to_point_dur:
		global_position = lerp(global_position, strafe_points[new_point].global_position, timer / to_point_dur)
		global_rotation.y = lerp(global_rotation.y, strafe_points[new_point].global_rotation.y, timer / to_point_dur)
		timer += delta
		await get_tree().process_frame
	
	cur_strafe_point = new_point

func triple_shot() -> void:
	for i in strafe_shot_num:
		shoot(strafe_shot_obj, strafe_shot_dmg)
		await get_tree().create_timer(strafe_shot_gap).timeout
#endregion

#region Charge Shooting
func charge_state() -> void:
	await to_charge_point()
	await charge_up_shot()
	await shoot_charge_shot()
	await to_centre()

func to_charge_point() -> void:
	# move to charge point
	var timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var to_charge_dur: float = abs(global_position.distance_to(charge_point.global_position)) / strafe_spd
	
	while timer < to_charge_dur:
		global_position = lerp(global_position, charge_point.global_position, timer / to_charge_dur)
		global_rotation.y = lerp(global_rotation.y, charge_point.global_rotation.y, timer / to_charge_dur)
		timer += delta
		await get_tree().process_frame

func charge_up_shot() -> void:
	var timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var blink_dur: float = (charge_up_time / charge_blink_num) / 2.0
	var original_colour: Color = material.albedo_color
	
	for i in charge_blink_num:
		# lerp to blink colour
		timer = 0.0
		while timer < blink_dur:
			material.albedo_color = lerp(original_colour, charge_blink_colour, timer / charge_blink_num)
			timer += delta
			await get_tree().process_frame
		
		# lerp to original colour
		timer = 0.0
		while timer < blink_dur:
			material.albedo_color = lerp(charge_blink_colour, original_colour, timer / charge_blink_num)
			timer += delta
			await get_tree().process_frame
		
		material.albedo_color = original_colour

func shoot_charge_shot() -> void:
	for i in charge_shot_num:
		shoot(charge_shot_obj, charge_shot_dmg)
		await get_tree().create_timer(charge_shot_gap).timeout
#endregion

#region Laser Firing
func laser_state() -> void:
	await exit_screen()
	await get_tree().create_timer(laser_start_wait).timeout
	laser.visible = true
	laser_collider.disabled = false
	var first: bool = true
	for i in laser_heights.size():
		set_new_laser_height(laser_heights[i])
		teleport_to_laser_point(first)
		await to_laser_point(!first)
		first = !first
		await get_tree().create_timer(laser_mid_wait).timeout
	laser_collider.disabled = true
	laser.visible = false
	await get_tree().create_timer(laser_end_wait).timeout
	await enter_screen()

func teleport_to_laser_point(first: bool) -> void:
	global_position = laser_point_1.global_position if first else laser_point_2.global_position

func to_laser_point(first: bool) -> void:
	# move to laser point
	var start: Node3D = laser_point_2 if first else laser_point_1
	var dest: Node3D = laser_point_1 if first else laser_point_2
	var timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var to_laser_dur: float = abs(global_position.distance_to(dest.global_position)) / laser_spd
	
	while timer < to_laser_dur:
		global_position = lerp(start.global_position, dest.global_position, timer / to_laser_dur)
		global_rotation.y = lerp(start.global_rotation.y, dest.global_rotation.y, timer / to_laser_dur)
		timer += delta
		await get_tree().process_frame

func set_new_laser_height(height: float) -> void:
	laser_point_1.global_position.y = height
	laser_point_2.global_position.y = height

func _on_laser_body_entered(body: Node3D) -> void:
	if body is Player:
		body.take_damage(laser_dmg)

#endregion
