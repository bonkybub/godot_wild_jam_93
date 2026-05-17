extends CanvasLayer

@onready var win_screen: CanvasLayer = $Win
@onready var lose_screen: CanvasLayer = $Death


@onready var hyperdrive_scene_path: String = "res://Scenes/HyperDriveScene.tscn"
@onready var mainmenu_scene_path: String = "res://Scenes/main_menu.tscn"


var game_ended: bool = false


func _ready() -> void:
	hide_screens()


func show_win_screen() -> void:
	if game_ended:
		return

	game_ended = true
	
	win_screen.visible = true
	lose_screen.visible = false
	
	get_tree().paused = true



func show_lose_screen() -> void:
	if game_ended:
		return

	game_ended = true
	get_tree().paused = true
	
	win_screen.visible = false
	lose_screen.visible = true


func hide_screens() -> void:
	get_tree().paused = false

	if win_screen != null:
		win_screen.visible = false

	if lose_screen != null:
		lose_screen.visible = false



func _on_win_button_pressed() -> void:
	get_tree().paused = false
	hide_screens()
	WarpTransition.transition_to_scene(hyperdrive_scene_path)


func _on_death_button_pressed() -> void:
	get_tree().paused = false
	hide_screens()
	WarpTransition.transition_to_scene(mainmenu_scene_path)
