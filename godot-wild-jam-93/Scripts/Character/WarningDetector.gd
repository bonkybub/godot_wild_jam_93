extends RayCast3D

@export var warning_stick: MeshInstance3D

@export var normal_color: Color = Color.WHITE
@export var warning_color: Color = Color.RED

var warning_material: StandardMaterial3D

func _ready() -> void:
	enabled = true
	collide_with_areas = true

	warning_material = StandardMaterial3D.new()
	warning_material.albedo_color = normal_color

	if warning_stick != null:
		warning_stick.material_override = warning_material

func _physics_process(_delta: float) -> void:
	if warning_stick == null:
		return

	if is_colliding():
		set_warning_active(true)
	else:
		set_warning_active(false)

func set_warning_active(is_active: bool) -> void:
	if is_active:
		warning_material.albedo_color = warning_color
	else:
		warning_material.albedo_color = normal_color
