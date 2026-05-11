extends Area3D

const SHOOT_SPEED: float = 2.0
const LIFETIME: float = 2.0
var death_timer: float = 0.0

func _ready() -> void:
	await get_tree().create_timer(LIFETIME).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	global_position += transform.basis.z * SHOOT_SPEED

func _on_body_entered(_body: Node3D) -> void:
	queue_free()
