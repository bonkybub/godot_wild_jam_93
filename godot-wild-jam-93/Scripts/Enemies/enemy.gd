class_name Enemy
extends CharacterBody3D

var spawner: ObstacleSpawner

@export_category("Health & Damage")
@export var fire_location: Node3D
@export var bullet_obj: PackedScene
@export var max_health: int = 30
var current_health: int
@export var shot_dmg: int = 10
@export var shot_spd: float = 10.0
@export var fire_dur: float = 0.1
@export var fire_scale: float = 1.3
@export var mesh: MeshInstance3D
@export var hit_colour: Color = Color.DARK_RED
@export var hit_pop_dur: float = 0.2
@export var hit_pop_scale: float = 1.2

@export_category("Death Pop")
@export var death_pop_dur: float = 0.1
@export var death_pop_scale: float = 1.5

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	current_health = max_health
	
	if mesh == null:
		for child in get_children():
			if is_instance_of(child, MeshInstance3D):
				mesh = child
				break
	
	var material = mesh.get_active_material(0)
	mesh.set_surface_override_material(0, material.duplicate())

func shoot() -> void:
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var start_scale: Vector3 = fire_location.scale
	var end_scale: Vector3 = fire_scale * Vector3.ONE
	while (timer < fire_dur):
		fire_location.scale = lerp(start_scale, end_scale, timer / fire_dur)
		timer += delta
		await get_tree().process_frame
	
	var bullet: Projectile = bullet_obj.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.add_to_group("enemy_projectile")
	bullet.global_position = fire_location.global_position
	bullet.damage = shot_dmg
	bullet.speed = shot_spd
	bullet.setup(spawner.player.global_position - bullet.global_position)
	
	timer = 0.0
	while (timer < (fire_dur * 2.0)):
		fire_location.scale = lerp(end_scale, start_scale, timer / (fire_dur * 2.0))
		timer += delta
		await get_tree().process_frame

func damage_dealt(dmg: int) -> void:
	current_health -= dmg
	
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var start_scale: Vector3 = scale
	var end_scale: Vector3 = hit_pop_scale * Vector3.ONE
	
	# set to hit colour and expand mesh
	var material = mesh.get_active_material(0)
	var original_colour
	if material is StandardMaterial3D:
		original_colour = material.albedo_color
		material.albedo_color = hit_colour
	
	# check for death
	if current_health <= 0.0:
		death()
		return
	
	while (timer < death_pop_dur):
		if timer / death_pop_dur <= 0.5:
			scale = lerp(start_scale, end_scale, timer / (death_pop_dur * 0.5))
		else:
			scale = lerp(end_scale, start_scale, timer / (death_pop_dur * 0.5))
		timer += delta
		await get_tree().process_frame
	
	# set back to original values
	scale = start_scale
	if material is StandardMaterial3D:
		material.albedo_color = original_colour

func death() -> void:
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var end_scale: Vector3 = death_pop_scale * Vector3.ONE
	
	while (timer < death_pop_dur):
		scale = lerp(Vector3.ONE, end_scale, timer / death_pop_dur)
		timer += delta
		await get_tree().process_frame
	
	queue_free()
