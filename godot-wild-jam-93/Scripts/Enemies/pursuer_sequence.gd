class_name PursuerSequence
extends Path3D

var active_pursuers: Array[Pursuer]
var shoot_count: int = 0

@export var y_bounds: Vector2 = Vector2(0.5, 2.5)

func setup_position() -> void:
	position.y = randf_range(y_bounds.x, y_bounds.y)
