extends Area3D

@export var speed: float = 35.0
@export var life_time: float = 3.0

var move_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += move_direction * speed * delta

func setup(direction: Vector3) -> void:
	move_direction = direction.normalized()
