class_name ObstacleSpawner
extends Node3D

@export var player: Player

#region Bandit Spawning
@onready var bandit_ent_path_l: Path3D = $"Bandit Enter Path (Left)"
@onready var bandit_ent_path_r: Path3D = $"Bandit Enter Path (Right)"
@onready var bandit_ex_path_l: Path3D = $"Bandit Exit Path (Left)"
@onready var bandit_ex_path_r: Path3D = $"Bandit Exit Path (Right)"

@export_category("Bandit Spawning")
@export var bandit_obj: PackedScene
@export var bandit_group: BanditGroup
@export var bandit_z_plane: float = -5.0
@export var bandit_spawn_min: int = 3
@export var bandit_spawn_max: int = 5
@export var bandit_pre_wait: float = 2.0
@export var bandit_spawn_gap: float = 2.0
# amount of seconds before spawning next bandit in group
@export var bandit_enter_gap: float = 0.3
@export var bandit_enter_spd: float = 25.0
@export var bandit_ease_in_dur: float = 1.0
@export var bandit_left_range: Vector2 = Vector2(-11.0, -7.0)
@export var bandit_right_range: Vector2 = Vector2(7.0, 11.0)
@export var bandit_height_range: Vector2 = Vector2(0.5, 2.5)
@export var bandit_exit_gap: float = 0.5
@export var bandit_exit_spd: float = 15.0
@export var bandit_ease_out_dur: float = 0.6
var bandit_follow: PathFollow3D
var bandit_points: Array[Node3D]
#endregion

#region Obstacle Spawning
@export_category("Cactus Spawning")
@export var cactus_obj: PackedScene
@export var cactus_spawn_gap: float = 2.0
@export var cactus_start_num: int = 10
@export var cactus_spawn_num: int = 2
@export var cactus_x_bounds: Vector2 = Vector2(-6.0, 6.0)
@export var cactus_y_bounds: Vector2 = Vector2(-2.0, 5.0)
@export var cactus_z_bounds: Vector2 = Vector2(-70.0, -65.0)
@export var cactus_z_limit: float = 5.0
@export var cactus_start_z_bound: float = -30.0
#endregion

func _ready() -> void:
	start_bandits()
	start_cacti()

func remove_from_path(path_follow: PathFollow3D, new_parent: Node3D, child: Node3D) -> void:
	var pos: Vector3 = child.global_position
	var rot: Vector3 = child.global_rotation
	path_follow.remove_child(child)
	new_parent.add_child(child)
	child.global_position = pos
	child.global_rotation = rot

#region Bandits
func start_bandits() -> void:
	await get_tree().create_timer(bandit_pre_wait).timeout
	
	while (true):
		await bandit_cycle()
		await get_tree().create_timer(bandit_spawn_gap).timeout

func bandit_cycle() -> void:
	# selecting the position the bandit group will fly into
	var path: Path3D
	var side: float = randf()
	if side < 0.5:
		bandit_follow = bandit_ent_path_l.get_child(0)
		var x: float = randf_range(bandit_left_range.x, bandit_left_range.y)
		var y: float = randf_range(bandit_height_range.x, bandit_height_range.y)
		var z: float = bandit_ent_path_l.global_position.z
		bandit_ent_path_l.global_position = Vector3(x, y ,z)
		path = bandit_ent_path_l
	else:
		bandit_follow = bandit_ent_path_r.get_child(0)
		var x: float = randf_range(bandit_right_range.x, bandit_right_range.y)
		var y: float = randf_range(bandit_height_range.x, bandit_height_range.y)
		var z: float = bandit_ent_path_r.global_position.z
		bandit_ent_path_r.global_position = Vector3(x, y ,z)
		path = bandit_ent_path_r
	
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
		if i == spawn_count - 1:
			await spawn_bandit(i, path_follow)
		else:
			spawn_bandit(i, path_follow)
			await get_tree().create_timer(bandit_enter_gap).timeout
	
	# start strafing and shooting
	await bandit_group.start_group()
	
	if bandit_group.position.distance_to(bandit_ex_path_l.position) < bandit_group.position.distance_to(bandit_ex_path_r.position):
		bandit_follow = bandit_ex_path_l.get_child(0)
	else:
		bandit_follow = bandit_ex_path_r.get_child(0)
	
	# bandits fly out
	for i in bandit_group.active_bandits.size():
		var path_follow: PathFollow3D = bandit_follow.duplicate()
		bandit_follow.get_parent_node_3d().add_child(path_follow)
		despawn_bandit(path_follow)
		await get_tree().create_timer(bandit_exit_gap).timeout
	
	for bandit in bandit_group.active_bandits:
		bandit.queue_free()
	
	bandit_group.active_bandits.clear()

func spawn_bandit(id: int, path_follow: PathFollow3D) -> void:
	var delta: float = get_physics_process_delta_time()
	var bandit: Bandit = bandit_obj.instantiate()
	bandit.spawner = self
	bandit.group = bandit_group
	bandit_group.active_bandits.push_back(bandit)
	path_follow.add_child(bandit)
	path_follow.progress_ratio = 0.0
	
	# follow path at move speed
	while (path_follow.progress_ratio < 1.0):
		path_follow.progress += bandit_enter_spd * delta
		await get_tree().process_frame
	
	if bandit == null: return
	
	# remove bandit from path follow
	remove_from_path(path_follow, bandit_points[id], bandit)
	var bandit_pos: Vector3 = bandit.global_position
	
	# move bandit to associated group point
	var ease_in_timer: float = 0.0
	while (ease_in_timer < bandit_ease_in_dur):
		if bandit == null: return
		bandit.global_position = lerp(bandit_pos, bandit_points[id].global_position, ease_in_timer / bandit_ease_in_dur)
		ease_in_timer += delta
		await get_tree().process_frame
	
	path_follow.queue_free()
	if bandit != null: bandit.animator.play("bandit_idle")

func despawn_bandit(path_follow: PathFollow3D) -> void:
	var ease_out_timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var bandit: Bandit = bandit_group.active_bandits.pop_front()
	if bandit == null: return
	var bandit_pos: Vector3 = bandit.global_position
	bandit.get_parent_node_3d().remove_child(bandit)
	self.add_child(bandit)
	bandit.animator.stop()
	
	# ease into start position of path follow
	while ease_out_timer < bandit_ease_out_dur:
		if bandit == null: return
		bandit.global_position = lerp(bandit_pos, path_follow.get_parent_node_3d().global_position, ease_out_timer / bandit_ease_out_dur)
		ease_out_timer += delta
		await get_tree().process_frame
	
	bandit.rotation_degrees.y += 180
	bandit.get_parent_node_3d().remove_child(bandit)
	path_follow.add_child(bandit)
	bandit.position = Vector3.ZERO
	path_follow.progress_ratio = 0.0
	
	# follow path at move speed
	while (path_follow.progress_ratio < 1.0):
		path_follow.progress += bandit_exit_spd * delta
		await get_tree().process_frame
	
	path_follow.queue_free()
#endregion

func start_cacti() -> void:
	while (true):
		for i in cactus_spawn_num:
			var cactus: CactusBall = cactus_obj.instantiate()
			get_tree().current_scene.add_child.call_deferred(cactus)
			var x: float = randf_range(cactus_x_bounds.x, cactus_x_bounds.y) + global_position.x
			var y: float = randf_range(cactus_y_bounds.x, cactus_y_bounds.y) + global_position.y
			var z: float = randf_range(cactus_z_bounds.x, cactus_z_bounds.y) + global_position.z
			await get_tree().process_frame
			cactus.global_position = Vector3(x, y, z)
			cactus.set_sway_positions()
			cactus.spawner = self
		await get_tree().create_timer(cactus_spawn_gap).timeout
