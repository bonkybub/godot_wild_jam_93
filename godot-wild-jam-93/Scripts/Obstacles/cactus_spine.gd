extends Area3D

const SHOOT_SPEED: float = 2.0
const LIFETIME: float = 2.0
var death_timer: float = 0.0

func _physics_process(delta: float) -> void:
	global_position += transform.basis.z * SHOOT_SPEED
	
	# destroy after lifetime countdown
	death_timer += delta
	if death_timer >= LIFETIME:
		queue_free()
