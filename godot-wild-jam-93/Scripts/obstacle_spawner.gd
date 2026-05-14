class_name ObstacleSpawner
extends Node3D

#region Bandit Pathing
@onready var bandit_path_l: Path3D = $"Bandit Path (Left)"
@onready var bandit_follow_l: PathFollow3D = $"Bandit Path (Left)/PathFollow3D"
@onready var bandit_path_r: Path3D = $"Bandit Path (Right)"
@onready var bandit_follow_r: PathFollow3D = $"Bandit Path (Right)/PathFollow3D"

@export_category("Bandit Spawning")
@export var bandit_obj: PackedScene
@export var bandit_group: BanditGroup
@export var bandit_z_plane: float = -5.0
@export var bandit_spawn_min: int = 3
@export var bandit_spawn_max: int = 5
var bandit_spawn_timer: float = 8.0
@export var bandit_spawn_gap: float = 10.0
var bandit_enter_timer: float = 0.0
# amount of seconds before spawning next bandit in group
@export var bandit_enter_gap: float = 0.3
@export var bandit_enter_spd: float = 25.0
@export var bandit_ease_in_dur: float = 1.0
@export var bandit_left_range: Vector2 = Vector2(-11.0, -7.0)
@export var bandit_right_range: Vector2 = Vector2(7.0, 11.0)
@export var bandit_height_range: Vector2 = Vector2(-0.5, 3.5)
var bandit_spawning: bool = false
var bandit_follow: PathFollow3D
var bandit_points: Array[Node3D]
var active_bandits: Array[CharacterBody3D]
#endregion

func _process(delta: float) -> void:
	if !bandit_spawning:
		bandit_spawn_timer += delta
	
	if !bandit_spawning && bandit_spawn_timer >= bandit_spawn_gap:
		bandit_spawning = true
		bandit_spawn_timer = 0.0
		bandit_spawn_select()

func remove_from_path(path_follow: PathFollow3D, new_parent: Node3D, child: Node3D) -> void:
	var pos: Vector3 = child.global_position
	var rot: Vector3 = child.global_rotation
	path_follow.remove_child(child)
	new_parent.add_child(child)
	child.global_position = pos
	child.global_rotation = rot

func bandit_spawn_select():
	# selecting the position the bandit group will fly into
	var path: Path3D
	var side: float = randf()
	if side < 0.5:
		bandit_follow = bandit_follow_l
		var x: float = randf_range(bandit_left_range.x, bandit_left_range.y)
		var y: float = randf_range(bandit_height_range.x, bandit_height_range.y)
		var z: float = bandit_path_l.global_position.z
		bandit_path_l.global_position = Vector3(x, y ,z)
		path = bandit_path_l
	else:
		bandit_follow = bandit_follow_r
		var x: float = randf_range(bandit_right_range.x, bandit_right_range.y)
		var y: float = randf_range(bandit_height_range.x, bandit_height_range.y)
		var z: float = bandit_path_r.global_position.z
		bandit_path_r.global_position = Vector3(x, y ,z)
		path = bandit_path_r
	
	# set bandit group position
	bandit_group.global_position = path.curve.get_point_position(path.curve.point_count - 1) + path.global_position
	bandit_group.position.z = bandit_z_plane
	
	# selecting the number of bandits to spawn
	var spawn_count: int = randi_range(bandit_spawn_min, bandit_spawn_max)
	match spawn_count:
		3: bandit_points = bandit_group.three_group
		4: bandit_points = bandit_group.four_group
		5: bandit_points = bandit_group.five_group
	for i in spawn_count:
		var path_follow: PathFollow3D = bandit_follow.duplicate()
		bandit_follow.get_parent_node_3d().add_child(path_follow)
		spawn_bandit(i, path_follow)
		await get_tree().create_timer(bandit_enter_gap).timeout
	
	bandit_spawning = false

func spawn_bandit(id: int, path_follow: PathFollow3D) -> void:
	var delta: float = get_physics_process_delta_time()
	var bandit: Enemy = bandit_obj.instantiate()
	bandit.spawner = self
	active_bandits.push_back(bandit)
	path_follow.add_child(bandit)
	path_follow.progress_ratio = 0.0
	
	# follow path at move speed
	while (path_follow.progress_ratio < 1.0):
		path_follow.progress += bandit_enter_spd * delta
		await get_tree().process_frame
	
	if bandit == null: return
	
	# remove bandit from path follow
	remove_from_path(path_follow, self, bandit)
	var bandit_pos = bandit.global_position
	
	# move bandit to associated group point
	var ease_in_timer: float = 0.0
	while (ease_in_timer < bandit_ease_in_dur):
		if bandit == null: return
		bandit.global_position = lerp(bandit_pos, bandit_points[id].global_position, ease_in_timer / bandit_ease_in_dur)
		ease_in_timer += delta
		await get_tree().process_frame
	
	path_follow.queue_free()
