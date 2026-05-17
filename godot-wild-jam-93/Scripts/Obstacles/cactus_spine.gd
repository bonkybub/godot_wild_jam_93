extends Area3D

const SHOOT_SPEED: float = 2.0
const LIFETIME: float = 2.0
@export var damage: int = 10

func _ready() -> void:
	await get_tree().create_timer(LIFETIME).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	global_position += -transform.basis.z * SHOOT_SPEED

func _on_body_entered(body: Node3D) -> void:
	# deal damage to enemy
	if body is Enemy && body.is_in_group("enemy"):
		(body as Enemy).damage_dealt(damage)
	queue_free()
