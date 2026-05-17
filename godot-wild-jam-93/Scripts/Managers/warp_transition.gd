extends Control

#region References
@export var warp_rect: ColorRect
#endregion

#region Transition Values
@export var fade_in_duration: float = 1.0
@export var fade_out_duration: float = 0.5

@export var start_speed: float = 1.0
@export var end_speed: float = 10.0

@export var fade_out_after_scene_change: bool = true

@export var hold_duration: float = 0.25
#endregion

#region Private Values
var warp_material: ShaderMaterial
var is_transitioning: bool = false
#endregion


func _ready() -> void:

	if warp_rect != null: 
		warp_material = warp_rect.material as ShaderMaterial
		
		warp_rect.visible = false
		_set_shader_values(0.0, start_speed)


func transition_to_scene(scene_path: String) -> void:
	if is_transitioning:
		return

	if warp_material == null:
		get_tree().change_scene_to_file(scene_path)
		return

	is_transitioning = true
	warp_rect.visible = true

	var speed_ramp_duration: float = fade_in_duration + hold_duration

	await _fade_warp_with_speed_ramp(
		0.0,
		1.0,
		start_speed,
		end_speed,
		fade_in_duration,
		speed_ramp_duration
	)

	get_tree().change_scene_to_file(scene_path)

	if hold_duration > 0.0:
		await _hold_warp_speed_ramp(fade_in_duration, speed_ramp_duration)

	if fade_out_after_scene_change:
		await get_tree().process_frame
		await _fade_warp(1.0, 0.0, end_speed, start_speed, fade_out_duration)
	else:
		_set_shader_values(0.0, start_speed)

	warp_rect.visible = false
	is_transitioning = false

#region Speed ramp up stuff

func _fade_warp_with_speed_ramp(
	start_opacity: float,
	target_opacity: float,
	from_speed: float,
	to_speed: float,
	opacity_duration: float,
	speed_duration: float
) -> void:
	var timer: float = 0.0

	while timer < opacity_duration:
		var opacity_t: float = timer / opacity_duration
		var speed_t: float = timer / speed_duration

		var current_opacity: float = lerpf(start_opacity, target_opacity, opacity_t)
		var current_speed: float = lerpf(from_speed, to_speed, speed_t)

		_set_shader_values(current_opacity, current_speed)

		timer += get_process_delta_time()
		await get_tree().process_frame

	var final_speed_t: float = opacity_duration / speed_duration
	var final_speed: float = lerpf(from_speed, to_speed, final_speed_t)

	_set_shader_values(target_opacity, final_speed)


func _hold_warp_speed_ramp(start_time: float, speed_duration: float) -> void:
	var timer: float = start_time

	while timer < speed_duration:
		var speed_t: float = timer / speed_duration
		var current_speed: float = lerpf(start_speed, end_speed, speed_t)

		_set_shader_values(1.0, current_speed)

		timer += get_process_delta_time()
		await get_tree().process_frame

	_set_shader_values(1.0, end_speed)

#endregion

func _fade_warp(start_opacity: float, target_opacity: float, from_speed: float, to_speed: float, duration: float) -> void:
	var timer: float = 0.0

	while timer < duration:
		var t: float = timer / duration

		var current_opacity: float = lerpf(start_opacity, target_opacity, t)
		var current_speed: float = lerpf(from_speed, to_speed, t)

		_set_shader_values(current_opacity, current_speed)

		timer += get_process_delta_time()
		await get_tree().process_frame

	_set_shader_values(target_opacity, to_speed)


func _set_shader_values(new_opacity: float, new_speed: float) -> void:
	if warp_material == null:
		return

	warp_material.set_shader_parameter("opacity", new_opacity)
	warp_material.set_shader_parameter("speed", new_speed)
