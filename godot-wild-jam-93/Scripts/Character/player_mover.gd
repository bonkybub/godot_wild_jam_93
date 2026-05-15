class_name PlayerMover
extends Node3D

var move_speed: float = 5.0

func _physics_process(delta: float) -> void:
	position.z -= move_speed * delta


func _on_speed_upgrade_pressed() -> void:
	
	pass # Replace with function body.
