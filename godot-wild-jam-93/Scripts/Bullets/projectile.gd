extends Area3D

@export var speed: float = 35.0
@export var life_time: float = 3.0
@export var damage: int = 20

var move_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += move_direction * speed * delta

func setup(direction: Vector3) -> void:
	move_direction = direction.normalized()

func _on_body_entered(body: Node3D) -> void:
	if body is Enemy && body.is_in_group("enemy"):
		(body as Enemy).damage_dealt(damage)
