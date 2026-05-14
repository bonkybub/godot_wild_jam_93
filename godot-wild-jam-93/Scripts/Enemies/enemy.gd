class_name Enemy
extends CharacterBody3D

var spawner: ObstacleSpawner

@export_category("Death Pop")
@export var death_pop_dur: float = 0.1
@export var death_pop_scale: float = 1.5

func death() -> void:
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var end_scale: Vector3 = death_pop_scale * Vector3.ONE
	
	while (timer < death_pop_dur):
		scale = lerp(Vector3.ONE, end_scale, timer / death_pop_dur)
		timer += delta
		await get_tree().process_frame
	
	# TODO MATTHEW
	# make generic per enemy type
	if spawner.active_bandits.has(self):
		spawner.active_bandits.remove_at(spawner.active_bandits.find(self))
	queue_free()
