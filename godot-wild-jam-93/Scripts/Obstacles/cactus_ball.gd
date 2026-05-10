extends Obstacle

# sway positioning
@export var sway_range: float = 0.8
@export var sway_dur: float = 6.0

var sway_time: float = 0.0
var f_pos: Vector3
var s_pos: Vector3
var pos_axis: Vector3
var pos_amp: Vector3

# spines bursting
@export var spine_obj: PackedScene
@export var spine_count: int = 8

var enemies_nearby: Array[CharacterBody3D]

func _ready() -> void:
	var cur_pos: Vector3 = global_position
	var x_lower: float = cur_pos.x - sway_range
	var x_upper: float = cur_pos.x + sway_range
	var y_lower: float = cur_pos.y - sway_range
	var y_upper: float = cur_pos.y + sway_range
	f_pos = Vector3(randf_range(x_lower, x_upper), randf_range(y_lower, y_upper), cur_pos.z)
	s_pos = Vector3(randf_range(x_lower, x_upper), randf_range(y_lower, y_upper), cur_pos.z)
	pos_axis = (f_pos + s_pos) * 0.5
	pos_amp = f_pos - pos_axis

# float in place
# swaying slightly
func _physics_process(delta: float) -> void:
	# cosine function to sway between two points
	global_position = Vector3(sway_cos(pos_amp.x, pos_axis.x), sway_cos(pos_amp.y, pos_axis.y), sway_cos(pos_amp.z, pos_axis.z))
	sway_time += delta

func sway_cos(amp: float, axis: float) -> float:
	return amp * cos(((2 * PI) / sway_dur) * sway_time) + axis

# explodes when hit
# deals damage to enemies
# shoot around and aim at nearby enemies

func spine_burst() -> void:
	for i in spine_count:
		var spine: Area3D = spine_obj.instantiate()
		add_child(spine)

func _on_burst_radius_body_entered(body: Node3D) -> void:
	# add enemy to list of burst targets
	if body is CharacterBody3D:
		enemies_nearby.push_back(body)

func _on_burst_radius_body_exited(body: Node3D) -> void:
	# remove enemy from list of burst targets
	if body is CharacterBody3D && enemies_nearby.has(body):
		enemies_nearby.pop_at(enemies_nearby.find(body))
