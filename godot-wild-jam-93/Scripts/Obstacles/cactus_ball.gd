class_name CactusBall
extends Obstacle

# sway positioning
@export_category("Idle Sway")
@export var sway_range: float = 0.8
@export var sway_dur: float = 6.0
@export var min_spin_spd: float = 1.0
@export var max_spin_spd: float = 3.0

var sway_time: float = 0.0
var f_pos: Vector3
var s_pos: Vector3
var pos_axis: Vector3
var pos_amp: Vector3

var spin_spd: float
var spin_dir: Vector3

# spines bursting
@export_category("Spine Burst")
@export var spine_obj: PackedScene
@export var spine_count: int = 8
var spine_directions: Array[float]

var enemies_nearby: Array[CharacterBody3D]

func _ready() -> void:
	set_sway_positions()
	
	spin_spd = randf_range(min_spin_spd, max_spin_spd)
	spin_dir = Vector3(randf_range(-360, 360), randf_range(-360, 360), randf_range(-360, 360))
	spin_dir = spin_dir.normalized()
	
	for i in spine_count:
		spine_directions.push_back(i * (360.0 / spine_count))

# float in place
# swaying slightly
func _physics_process(delta: float) -> void:
	# cosine function to sway between two points
	global_position = Vector3(sway_cos(pos_amp.x, pos_axis.x), sway_cos(pos_amp.y, pos_axis.y), sway_cos(pos_amp.z, pos_axis.z))
	sway_time += delta
	rotation_degrees += spin_spd * spin_dir
	
	if spawner != null:
		if global_position.z >= spawner.cactus_z_limit:
			queue_free()

func set_sway_positions() -> void:
	var cur_pos: Vector3 = global_position
	var x_lower: float = cur_pos.x - sway_range
	var x_upper: float = cur_pos.x + sway_range
	var y_lower: float = cur_pos.y - sway_range
	var y_upper: float = cur_pos.y + sway_range
	f_pos = Vector3(randf_range(x_lower, x_upper), randf_range(y_lower, y_upper), cur_pos.z)
	s_pos = Vector3(randf_range(x_lower, x_upper), randf_range(y_lower, y_upper), cur_pos.z)
	pos_axis = (f_pos + s_pos) * 0.5
	pos_amp = f_pos - pos_axis

func sway_cos(amp: float, axis: float) -> float:
	return amp * cos(((2 * PI) / sway_dur) * sway_time) + axis

# explodes when hit
# deals damage to enemies
# shoot around and aim at nearby enemies
func spine_burst() -> void:
	# spawn spines to shoot around cactus
	for i in spine_count:
		var spine: Area3D = spine_obj.instantiate()
		get_tree().current_scene.add_child(spine)
		spine.global_position = global_position
		spine.rotation_degrees.y = spine_directions[i]
	
	for e in enemies_nearby:
		var spine: Area3D = spine_obj.instantiate()
		get_tree().current_scene.add_child(spine)
		spine.global_position = global_position
		spine.look_at(e.global_position)

func destroy_obstacle() -> void:
	spine_burst()
	enemies_nearby.clear()
	await death_pop()
	queue_free()

func _on_burst_radius_body_entered(body: Node3D) -> void:
	# add enemy to list of burst targets
	if body is CharacterBody3D && body.is_in_group("enemy"):
		enemies_nearby.push_back(body)

func _on_burst_radius_body_exited(body: Node3D) -> void:
	# remove enemy from list of burst targets
	if body is CharacterBody3D && body.is_in_group("enemy") && enemies_nearby.has(body):
		enemies_nearby.pop_at(enemies_nearby.find(body))
