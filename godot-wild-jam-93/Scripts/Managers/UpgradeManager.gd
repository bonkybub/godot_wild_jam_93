extends Control

#region References
@onready var player: Node3D = $"../Player Mover/Player"


@onready var HpLabel: Label = $Upgrades/Health/HpLabel
@onready var DmgLabel: Label = $Upgrades/Damage/DmgLabel
@onready var SpeedLabel: Label = $Upgrades/Speed/SpeedLabel

@onready var MoneyLabel: Label = $Schmoney
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MoneyLabel.text = "Money: " + str(GameManager.player_money)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	pass # Replace with function body.

#region Base Upgrades

func _on_hp_upgrade_pressed() -> void:
	GameManager.increase_player_health(5)
	HpLabel.text = "Health: " + str(GameManager.player_hp)
	pass # Replace with function body.


func _on_dmg_upgrade_pressed() -> void:
	GameManager.increase_player_damage(2.5)
	DmgLabel.text = "Damage: " + str(GameManager.player_damage)
	pass # Replace with function body.
 

func _on_speed_upgrade_pressed() -> void:
	GameManager.increase_player_speed(1)
	SpeedLabel.text = "Speed: " + str(GameManager.player_speed)
	
	pass # Replace with function body.

#endregion
