class_name Obstacle
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	print("body entered")
	# deal damage to player
	if body is Player:
		print("player hit")
