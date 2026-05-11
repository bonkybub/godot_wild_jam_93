extends Area3D

const SHOOT_SPEED: float = 2.0
const LIFETIME: float = 2.0
var death_timer: float = 0.0

func _ready() -> void:
	await get_tree().create_timer(LIFETIME).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	global_position += transform.basis.z * SHOOT_SPEED

func _on_body_entered(body: Node3D) -> void:
	# TODO MATTHEW
	# deal damage to enemy
	if body is CharacterBody3D && body.is_in_group("enemy"):
		pass
	queue_free()
