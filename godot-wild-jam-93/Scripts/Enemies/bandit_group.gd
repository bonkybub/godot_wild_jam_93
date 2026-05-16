class_name BanditGroup
extends Node3D

@export_category("Groups")
@export var three_group: Array[Node3D]
@export var four_group: Array[Node3D]
@export var five_group: Array[Node3D]

var active_bandits: Array[Bandit]
var bandits_to_shoot: Array[Bandit]

@export_category("Group Shoot")
@export var shoot_num: int = 2
@export var shoot_wait_dur: float = 0.4    # wait time before shooting starts and after shooting ends
@export var shoot_pause_dur: float = 1.2   # wait time between shooting first and second time
@export var shoot_gap: float = 0.8

@export_category("Group Strafe")
@export var strafe_x_range: Vector2 = Vector2(-4.0, 4.0)
@export var strafe_y_range: Vector2 = Vector2(0.5, 2.5)
@export var strafe_num: int = 2
@export var strafe_spd: float = 5.0
@export var strafe_dist: float = 2.0

func start_group() -> void:
	var tree: SceneTree = get_tree()
	await tree.create_timer(shoot_wait_dur).timeout
	await shoot()
	await tree.create_timer(shoot_wait_dur).timeout
	for i in strafe_num:
		var new_dest: Vector3 = Vector3(randf_range(strafe_x_range.x, strafe_x_range.y), randf_range(strafe_y_range.x, strafe_y_range.y), position.z)
		var new_dir: Vector3 = (new_dest - position).normalized()
		new_dest = strafe_dist * new_dir
		new_dest.z = position.z
		await strafe(new_dest, new_dest.x < global_position.x)
		await tree.create_timer(shoot_wait_dur).timeout
		await shoot()
		await tree.create_timer(shoot_wait_dur).timeout

func shoot() -> void:
	if active_bandits.is_empty(): return
	
	# set up wave shooting
	bandits_to_shoot.clear()
	bandits_to_shoot = active_bandits.duplicate()
	var wave_counts: Array[int]
	var remaining: int = bandits_to_shoot.size()
	for i in shoot_num:
		var num: int = ceil(remaining / float(shoot_num - i))
		wave_counts.push_back(num)
		remaining -= num
		if remaining <= 0: break
	
	for i in shoot_num:
		# get wave of shooters
		if i >= wave_counts.size(): break
		for j in wave_counts[i]:
			# select shooter in wave
			var id: int = randi_range(0, bandits_to_shoot.size() - 1)
			if bandits_to_shoot.is_empty() || bandits_to_shoot[id] == null: continue
			var shooter: Bandit = bandits_to_shoot[id]
			bandits_to_shoot.remove_at(id)
			shooter.shoot()
			await get_tree().create_timer(shoot_gap).timeout
		
		if i == shoot_num - 1: break
		# wait before next wave
		await get_tree().create_timer(shoot_pause_dur).timeout

func strafe(dest: Vector3, left: bool) -> void:
	var anim_name: String = "bandit_strafe_left" if left else "bandit_strafe_right"
	for bandit in active_bandits:
		bandit.animator.play(anim_name)
	
	var timer: float = 0.0
	var delta: float = get_physics_process_delta_time()
	var strafe_dur: float = position.distance_to(dest) / strafe_spd
	var start_pos: Vector3 = position
	
	while timer < strafe_dur:
		position = lerp(start_pos, dest, timer / strafe_dur)
		timer += delta
		await get_tree().process_frame
	
	position = dest
	for bandit in active_bandits:
		end_strafe(bandit, anim_name)

func end_strafe(bandit: Bandit, anim: String) -> void:
	bandit.animator.play_backwards(anim)
	await bandit.animator.animation_finished
	bandit.animator.play("bandit_idle")
