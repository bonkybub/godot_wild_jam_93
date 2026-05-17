extends Control

#region References
@onready var player: Node3D = $"../Player Mover/Player"

@onready var HpLabel: Label = $Upgrades/Health/HpLabel
@onready var HpButton: Button = $Upgrades/Health/HpUpgrade

@onready var DmgLabel: Label = $Upgrades/Damage/DmgLabel
@onready var DmgButton: Button = $Upgrades/Damage/DmgUpgrade

@onready var SpeedLabel: Label = $Upgrades/Speed/SpeedLabel
@onready var SpeedButton: Button = $Upgrades/Speed/SpeedUpgrade

@onready var DashButton: Button = $Upgrades/Dash/DashUnlock

@onready var ScatterButton: Button = $Upgrades/ScatterShot/ScatterUnlock

@onready var MoneyLabel: Label = $Schmoney

@onready var UpgradeMenu: Control = $"."
@onready var BountyMenu: Control = $"../BountyScreen"
#endregion


func _ready() -> void:
	
	UpgradeMenu.visible = true
	BountyMenu.visible = false
	
	update_upgrade_ui()


func _on_continue_pressed() -> void:
	
	UpgradeMenu.visible = false
	BountyMenu.visible = true
	
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")


#region Base Upgrades
func _on_hp_upgrade_pressed() -> void:
	GameManager.buy_health_upgrade()
	update_upgrade_ui()

func _on_dmg_upgrade_pressed() -> void:
	GameManager.buy_damage_upgrade()
	update_upgrade_ui()

func _on_speed_upgrade_pressed() -> void:
	GameManager.buy_speed_upgrade()
	update_upgrade_ui()
#endregion


#region Ability Unlocks
func _on_dash_unlock_pressed() -> void:
	GameManager.buy_dash_unlock()
	update_upgrade_ui()

func _on_scatter_unlock_pressed() -> void:
	GameManager.buy_scattershot_unlock()
	update_upgrade_ui()
#endregion


#region UI Stuff
func update_upgrade_ui() -> void:
	MoneyLabel.text = "Credits: " + str(GameManager.player_money)

	HpLabel.text = "Health: " + str(GameManager.player_hp)
	DmgLabel.text = "Damage: " + str(GameManager.player_damage)
	SpeedLabel.text = "Speed: " + str(GameManager.player_speed)

	HpButton.text = "Upgrade - " + str(GameManager.hp_upgrade_cost) + " Credits"
	DmgButton.text = "Upgrade - " + str(GameManager.damage_upgrade_cost) + " Credits"
	SpeedButton.text = "Upgrade - " + str(GameManager.speed_upgrade_cost) + " Credits"

	update_ability_button(DashButton, GameManager.player_canDash, GameManager.dash_unlock_cost)
	update_ability_button(ScatterButton, GameManager.player_hasScatterShot, GameManager.scattershot_unlock_cost)

func update_ability_button(button: Button, is_unlocked: bool, cost: int) -> void:
	if is_unlocked:
		button.text = "Unlocked"
		button.disabled = true
	else:
		button.text = "Unlock - " + str(cost) + " Credits"
		button.disabled = false
#endregion


func _on_bounty_button_1_pressed() -> void:
	GameManager.select_bounty(GameManager.BountyType.THE_SHERIFF)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_bounty_button_2_pressed() -> void:
	GameManager.select_bounty(GameManager.BountyType.RATTLESNAKE)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
