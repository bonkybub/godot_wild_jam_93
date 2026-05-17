extends Control

@export var hyperdrive_scene_path: String = "res://Scenes/HyperDriveScene.tscn"




func _on_start_button_pressed() -> void:
	WarpTransition.transition_to_scene(hyperdrive_scene_path)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
