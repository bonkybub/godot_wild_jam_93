extends Node3D

#region Animation Values
@export var vertical_move_amount: float = 0.15
@export var vertical_move_speed: float = 1.5

@export var forward_move_amount: float = 0.1
@export var forward_move_speed: float = 1.0

@export var rotate_amount: float = 3.0
@export var rotate_speed: float = 1.0
#endregion


var start_position: Vector3
var start_rotation: Vector3
var timer: float = 0.0


func _ready() -> void:
	start_position = position
	start_rotation = rotation_degrees

func _process(delta: float) -> void:
	timer += delta

	var vertical_offset := sin(timer * vertical_move_speed) * vertical_move_amount
	var forward_offset := sin(timer * forward_move_speed) * forward_move_amount
	var rotation_offset := sin(timer * rotate_speed) * rotate_amount

	position.y = start_position.y + vertical_offset
	position.z = start_position.z + forward_offset

	rotation_degrees.z = start_rotation.z + rotation_offset
