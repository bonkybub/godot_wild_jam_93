class_name Obstacle
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	print("body entered")
	# deal damage to player
	if body is Player:
		print("player hit")

func _on_area_entered(area: Area3D) -> void:
	# destroy if hit
	destroy_obstacle()

func destroy_obstacle() -> void:
	pass
	#queue_free()
