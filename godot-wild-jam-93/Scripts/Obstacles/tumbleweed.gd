extends Obstacle

# float and spin values
var float_velocity: Vector2
var float_direction: Vector2
var spin_speed: float
@export var max_h_vel: float = 0.06
@export var max_v_vel: float = 0.02
@export var min_spin_spd: float = 1.0
@export var max_spin_spd: float = 3.0

func _ready() -> void:
	# set speeds from ranges
	float_velocity = Vector2(randf_range(0.01, max_h_vel), randf_range(0.0, max_v_vel))
	spin_speed = randf_range(min_spin_spd, max_spin_spd)
	
	# set direction of motion
	if global_position.x > 0.0:
		float_velocity.x *= -1.0
	else:
		spin_speed *= -1.0
	
	# TODO MATTHEW
	# make not hard-coded
	if global_position.y > 1.5:
		float_velocity.y *= -1.0

# fly across screen
# spin constantly
func _physics_process(_delta: float) -> void:
	global_position += Vector3(float_velocity.x, float_velocity.y, 0.0)
	rotation_degrees.z += spin_speed
