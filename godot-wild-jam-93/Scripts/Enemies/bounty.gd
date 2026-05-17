class_name Bounty
extends Enemy

@export var hyperdrive_scene_path: String = "res://Scenes/HyperDriveScene.tscn"

func spawn() -> void:
	pass

func death() -> void:
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var end_scale: Vector3 = death_pop_scale * Vector3.ONE
	
	while (timer < death_pop_dur):
		scale = lerp(Vector3.ONE, end_scale, timer / death_pop_dur)
		timer += delta
		await get_tree().process_frame
	
	var e: Node3D = explosion.instantiate()
	get_tree().current_scene.add_child.call_deferred(e)
	await get_tree().process_frame
	e.global_position = global_position
	
	await get_tree().create_timer(3.0).timeout
	
	WarpTransition.transition_to_scene(hyperdrive_scene_path)
