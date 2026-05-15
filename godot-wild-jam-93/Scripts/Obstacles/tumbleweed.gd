class_name Tumbleweed
extends Obstacle

# float and spin values
var float_velocity: Vector2
var float_direction: Vector2
var spin_speed: float
@export var h_vel_bounds: Vector2 = Vector2(10.0, 14.0)
@export var v_vel_bounds: Vector2 = Vector2(1.0, 2.0)
@export var min_spin_spd: float = 90.0
@export var max_spin_spd: float = 270.0
@export var x_mid: float = 0.0
@export var y_mid: float = 1.5

func _ready() -> void:
	setup()

func setup() -> void:
	# set speeds from ranges
	float_velocity = Vector2(randf_range(h_vel_bounds.x, h_vel_bounds.y), randf_range(v_vel_bounds.x, v_vel_bounds.y))
	spin_speed = randf_range(min_spin_spd, max_spin_spd)
	
	# set direction of motion
	if global_position.x > x_mid:
		float_velocity.x *= -1.0
	else:
		spin_speed *= -1.0
	
	if global_position.y > y_mid:
		float_velocity.y *= -1.0

# fly across screen
# spin constantly
func _physics_process(delta: float) -> void:
	global_position += Vector3(float_velocity.x, float_velocity.y, 0.0) * delta
	rotation_degrees.z += spin_speed * delta
