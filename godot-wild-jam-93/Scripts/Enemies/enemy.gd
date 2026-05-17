class_name Enemy
extends CharacterBody3D

var spawner: ObstacleSpawner
var material: StandardMaterial3D

@export_category("Health & Damage")
@export var fire_locations: Array[Node3D]
@export var bullet_obj: PackedScene
@export var max_health: int = 30
var current_health: int
@export var shot_dmg: int = 5
@export var shot_spd: float = 10.0
@export var fire_dur: float = 0.1
@export var fire_scale: float = 1.3
@export var mesh: GeometryInstance3D
@export var hit_colour: Color = Color.DARK_RED
@export var hit_pop_dur: float = 0.1
@export var hit_pop_scale: float = 1.2
var taking_damage: bool = false

@export_category("Death Pop")
@export var death_pop_dur: float = 0.1
@export var death_pop_scale: float = 1.5
@export var explosion: PackedScene

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	current_health = max_health
	
	if mesh == null:
		for child in get_children():
			if is_instance_of(child, GeometryInstance3D):
				mesh = child
				break
	
	material = mesh.material_override
	if material != null:
		mesh.material_override = material.duplicate()
		material = mesh.material_override

func shoot(b_obj: PackedScene = bullet_obj, dmg: int = shot_dmg) -> void:
	if spawner.player == null: return
	if fire_locations.is_empty(): return
	
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var start_scales: Array[Vector3]
	for fire_location in fire_locations:
		start_scales.push_back(fire_location.scale)
	var end_scale: Vector3 = fire_scale * Vector3.ONE
	while (timer < fire_dur):
		for i in fire_locations.size():
			fire_locations[i].scale = lerp(start_scales[i], end_scale, timer / fire_dur)
		timer += delta
		await get_tree().process_frame
	
	for fire_location in fire_locations:
		if spawner.player == null: break
		var bullet: Projectile = b_obj.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.add_to_group("enemy_projectile")
		bullet.global_position = fire_location.global_position
		bullet.damage = dmg
		bullet.speed = shot_spd
		bullet.setup(spawner.player.global_position - bullet.global_position)
	
	timer = 0.0
	while (timer < (fire_dur * 2.0)):
		for i in fire_locations.size():
			fire_locations[i].scale = lerp(end_scale, start_scales[i], timer / (fire_dur * 2.0))
		timer += delta
		await get_tree().process_frame

func damage_dealt(dmg: int) -> void:
	current_health -= dmg
	
	var timer: float = 0.0
	var delta: float = get_process_delta_time()
	var start_scale: Vector3 = scale
	var end_scale: Vector3 = hit_pop_scale * Vector3.ONE
	
	# set to hit colour and expand mesh
	var original_colour
	if material is StandardMaterial3D:
		original_colour = material.albedo_color
		material.albedo_color = hit_colour
	
	# check for death
	if current_health <= 0.0:
		death()
		return
	
	if taking_damage: return
	
	taking_damage = true
	
	# grow
	while timer < hit_pop_dur:
		scale = lerp(start_scale, end_scale, timer / hit_pop_dur)
		timer += delta
		await get_tree().process_frame
	
	timer = 0.0
	
	# shrink
	while timer < hit_pop_dur:
		scale = lerp(end_scale, start_scale, timer / hit_pop_dur)
		timer += delta
		await get_tree().process_frame
	
	# set back to original values
	taking_damage = false
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
	
	var e: Node3D = explosion.instantiate()
	get_tree().current_scene.add_child.call_deferred(e)
	await get_tree().process_frame
	e.global_position = global_position
	
	queue_free()
