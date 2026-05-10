extends Node3D

@export var projectile_scene: PackedScene

@onready var muzzle: Marker3D = $Muzzle

var current_aim_point: Vector3 = Vector3.ZERO

func aim_at(target_position: Vector3) -> void:
	current_aim_point = target_position
	look_at(target_position, Vector3.UP)

func shoot() -> void:
	if projectile_scene == null:
		return

	var projectile := projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = muzzle.global_position

	var shoot_direction := current_aim_point - muzzle.global_position
	projectile.setup(shoot_direction)
