extends Node3D

#region Projectile Values
@export var projectile_scene: PackedScene
#endregion

#region Scattershot Values
var has_scattershot: bool = false

@export var scatter_projectile_count: int = 4
@export var scatter_angle_degrees: float = 12.0
@export var scatter_damage_multiplier: float = 0.333
#endregion

#region References
@onready var muzzle: Marker3D = $Muzzle
#endregion

#region Private Values
var current_aim_point: Vector3 = Vector3.ZERO
#endregion


func aim_at(target_position: Vector3) -> void:
	current_aim_point = target_position
	look_at(target_position, Vector3.UP)

func shoot() -> void:
	if projectile_scene == null:
		return

	if has_scattershot:
		shoot_scattershot()
	else:
		shoot_single_projectile(current_aim_point - muzzle.global_position, GameManager.player_damage)

func shoot_single_projectile(shoot_direction: Vector3, projectile_damage: int) -> void:
	var projectile := projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.add_to_group("player_projectile")

	projectile.global_position = muzzle.global_position
	projectile.setup(shoot_direction, projectile_damage)

func shoot_scattershot() -> void:
	var base_direction := (current_aim_point - muzzle.global_position).normalized()
	var scatter_damage: int = max(1, roundi(GameManager.player_damage * scatter_damage_multiplier))

	for i in scatter_projectile_count:
		var spread_percent := 0.0

		if scatter_projectile_count > 1:
			spread_percent = float(i) / float(scatter_projectile_count - 1)

		var angle_offset: float = lerpf(-scatter_angle_degrees, scatter_angle_degrees, spread_percent)
		var spread_direction: Vector3 = base_direction.rotated(Vector3.UP, deg_to_rad(angle_offset))

		shoot_single_projectile(spread_direction, scatter_damage)
