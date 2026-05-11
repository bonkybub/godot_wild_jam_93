class_name Obstacle
extends Area3D

@export var damage: int = 20

func _on_body_entered(body: Node3D) -> void:
	# deal damage to player
	if body is Player:
		print("player hit")
		body.take_damage(damage)
		destroy_obstacle()

func _on_area_entered(area: Area3D) -> void:
	# destroy if hit
	if area.is_in_group("player_projectile"):
		destroy_obstacle()

func destroy_obstacle() -> void:
	queue_free()
