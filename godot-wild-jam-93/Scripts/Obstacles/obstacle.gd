class_name Obstacle
extends Area3D

var spawner: ObstacleSpawner

@export var damage: int = 20

# death pop
@export_category("Death Pop")
@export var death_pop_dur: float = 0.1
@export var death_pop_scale: float = 2.0

func _physics_process(_delta: float) -> void:
	if spawner != null:
		if global_position.z >= spawner.obstacle_z_limit + spawner.global_position.z:
			queue_free()

func _on_body_entered(body: Node3D) -> void:
	# deal damage to player
	if body is Player:
		body.take_damage(damage)

func _on_area_entered(area: Area3D) -> void:
	# destroy if hit
	if area.is_in_group("player_projectile"):
		destroy_obstacle()

func destroy_obstacle() -> void:
	await death_pop()
	queue_free()

func death_pop() -> void:
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var end_scale: Vector3 = death_pop_scale * Vector3.ONE
	while (timer < death_pop_dur):
		scale = lerp(Vector3.ONE, end_scale, timer / death_pop_dur)
		timer += delta
		await get_tree().process_frame
	
	scale = Vector3(0.5, 0.5, 0.5)
