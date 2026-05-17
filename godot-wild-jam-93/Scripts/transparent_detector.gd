extends Camera3D

@export var transparent_dist: float = 2.0
@export var opaque_dist: float = 5.0
var dist_range: float

var close_objects: Array[Node3D]

func _enter_tree() -> void:
	dist_range = abs(opaque_dist - transparent_dist)

func _on_transparent_detector_body_entered(body: Node3D) -> void:
	if body is Enemy:
		close_objects.push_back(body)
		manage_transparency(body)

func _on_transparent_detector_area_entered(area: Area3D) -> void:
	if area is Obstacle:
		close_objects.push_back(area)
		manage_transparency(area)

func _on_transparent_detector_body_exited(body: Node3D) -> void:
	if close_objects.has(body) && body is Enemy:
		close_objects.remove_at(close_objects.find(body))

func _on_transparent_detector_area_exited(area: Area3D) -> void:
	if close_objects.has(area) && area is Obstacle:
		close_objects.remove_at(close_objects.find(area))

func manage_transparency(obj: Node3D) -> void:
	close_objects.push_back(obj)
	
	var mesh: GeometryInstance3D
	for child in obj.get_children():
		if child is GeometryInstance3D:
			mesh = child
	
	if mesh == null: return
	
	var material: StandardMaterial3D = mesh.material_override.duplicate()
	mesh.material_override = material
	
	while close_objects.has(obj):
		var z_diff: float = abs(global_position.z - obj.global_position.z)
		var z_ratio: float = (z_diff - transparent_dist) / dist_range
		material.albedo_color.a = lerp(0.0, 1.0, z_ratio)
		await get_tree().process_frame
	
	material.albedo_color.a = 1.0
