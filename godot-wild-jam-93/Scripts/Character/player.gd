class_name Player
extends CharacterBody3D
# Didn't know Godot gave you an example script, so I'm building it off of that

# Regions my beloved
#region Position Clamp
const MIN_X: float = -5.75
const MAX_X: float = 5.75
const MIN_Y: float = -2.0
const MAX_Y: float = 5.0
#endregion

#region Player Values
@export var SPEED: float = 5.0
@export var max_roll_degrees: float = 15.0
@export var max_pitch_degrees: float = 15.0
@export var rotation_smooth_speed: float = 6.0


@export var aim_plane_distance: float = 10.0

#endregion

#region References
@onready var ship_model: Node3D = $Model_Test

@onready var camera: Camera3D = $"../Camera3D"

@onready var gun_left: Node3D = $Model_Test/GunArm_Left/GunBase_Left
@onready var gun_right: Node3D = $Model_Test/GunArm_Right/GunBase_Right

@onready var aim_reticle: Node3D = $AimReticle
#endregion

#region Conditions
var shoot_from_left: bool = true

#endregion


#func _ready() -> void:
	# Keeping this off just to make testing easier
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("roll_left", "roll_right", "pitch_up", "pitch_down")
	var direction := Vector3(input_dir.x, input_dir.y, 0).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

	position.x = clamp(position.x, MIN_X, MAX_X)
	position.y = clamp(position.y, MIN_Y, MAX_Y)

	update_ship_rotation(input_dir, delta)
	update_gun_aim()
	handle_shooting()


func update_ship_rotation(input_dir: Vector2, delta: float) -> void:
	var target_pitch := deg_to_rad(input_dir.y * max_pitch_degrees)
	var target_roll := deg_to_rad(-input_dir.x * max_roll_degrees)

	ship_model.rotation.x = lerp_angle(ship_model.rotation.x, target_pitch, rotation_smooth_speed * delta)
	ship_model.rotation.z = lerp_angle(ship_model.rotation.z, target_roll, rotation_smooth_speed * delta)
	
	

func handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot") == false:
		return

	if shoot_from_left:
		gun_left.shoot()
	else:
		gun_right.shoot()

	shoot_from_left = !shoot_from_left

#region Gun Stuff
func update_gun_aim() -> void:
	var aim_point := get_mouse_aim_point()

	aim_reticle.global_position = aim_point
	aim_reticle.look_at(camera.global_position, Vector3.UP)

	gun_left.aim_at(aim_point)
	gun_right.aim_at(aim_point)

func get_mouse_aim_point() -> Vector3:
	var mouse_position := get_viewport().get_mouse_position()

	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	

	var plane_position := global_position + Vector3(0, 0, -aim_plane_distance)
	var aim_plane := Plane(Vector3.FORWARD, plane_position)

	var hit_position = aim_plane.intersects_ray(ray_origin, ray_direction)

	if hit_position == null:
		return global_position + Vector3(0, 0, -aim_plane_distance)

	return hit_position

#endregion
