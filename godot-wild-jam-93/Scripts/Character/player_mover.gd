class_name PlayerMover
extends Node3D

# TODO : Add some type of OFF mode so nothing spawns and the player interaction is turned off

var move_speed: float = 5.0

func _physics_process(delta: float) -> void:
	position.z -= move_speed * delta
