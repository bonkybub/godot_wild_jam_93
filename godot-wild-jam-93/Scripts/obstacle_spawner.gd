extends Node3D

@export var player_ship: Player

#region Bandit Pathing
@onready var bandit_path_l: Path3D = $"Bandit Path (Left)"
@onready var bandit_follow_l: PathFollow3D = $"Bandit Path (Left)/PathFollow3D"
@onready var bandit_path_r: Path3D = $"Bandit Path (Right)"
@onready var bandit_follow_r: PathFollow3D = $"Bandit Path (Right)/PathFollow3D"

@export_category("Banding Spawning")
@export var bandit_obj: PackedScene
@export var bandit_spawn_mix: int = 3
@export var bandit_spawn_max: int = 6
var bandit_spawn_timer: float = 8.0
@export var bandit_spawn_gap: float = 10.0
var bandit_enter_timer: float = 0.0
# amount of seconds before spawning next bandit in group
@export var bandit_enter_gap: float = 0.5
@export var bandit_enter_spd: float = 25.0
@export var bandit_ease_in_spd: float = 5.0
@export var bandit_left_range: Vector2 = Vector2(-16.0, -7.0)
@export var bandit_right_range: Vector2 = Vector2(7.0, 16.0)
@export var bandit_height_range: Vector2 = Vector2(-0.5, 3.5)
var bandit_spawning: bool = false
var bandit: CharacterBody3D
var bandit_follow: PathFollow3D
#endregion

func _process(delta: float) -> void:
	if !bandit_spawning:
		bandit_spawn_timer += delta
	
	if !bandit_spawning && bandit_spawn_timer >= bandit_spawn_gap:
		bandit_spawning = true
		bandit_spawn_timer = 0.0
		if bandit != null: bandit.queue_free()
		bandit = bandit_obj.instantiate()
		var side: float = randf()
		if side < 0.5:
			bandit_follow = bandit_follow_l
			var x: float = randf_range(bandit_left_range.x, bandit_left_range.y)
			var y: float = randf_range(bandit_height_range.x, bandit_height_range.y)
			var z: float = bandit_path_l.global_position.z
			bandit_path_l.global_position = Vector3(x, y ,z)
		else:
			bandit_follow = bandit_follow_r
			var x: float = randf_range(bandit_right_range.x, bandit_right_range.y)
			var y: float = randf_range(bandit_height_range.x, bandit_height_range.y)
			var z: float = bandit_path_r.global_position.z
			bandit_path_r.global_position = Vector3(x, y ,z)
		bandit_follow.add_child(bandit)
		bandit_follow.progress_ratio = 0.0

func _physics_process(delta: float) -> void:
	if bandit_spawning:
		if bandit_follow.progress_ratio < 0.9:
			bandit_follow.progress += bandit_enter_spd * delta
		else:
			bandit_follow.progress += bandit_ease_in_spd * delta
		
		if bandit_follow.progress_ratio >= 1.0:
			get_tree().current_scene.add_child(bandit)
			bandit_follow = null
			bandit_spawning = false
