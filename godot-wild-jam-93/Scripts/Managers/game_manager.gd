extends Node
# After figuring out how to make a singleton in godot, all player 'upgradeable' plyer values are gonne be stored here
# If we plan on scaling enemy hp, then we should also put it here

#region Player  Values /  Upgradeables

var player_hp: int = 100
var player_damage: int = 20
var player_speed: float = 5

var player_money: int = 10

var player_canDash: bool = false

#endregion


#region Player Upgrade Functions

func increase_player_health(amount: int) -> void:
	player_hp += amount
	print("Player health is now: ", player_speed)

func increase_player_damage(amount: int) -> void:
	player_damage += amount
	print("Player damage is now: ", player_speed)

func increase_player_speed(amount: float) -> void:
	player_speed += amount
	print("Player speed is now: ", player_speed)
	

func unlock_player_dash(isUnlocked: bool) -> void:
	player_canDash = isUnlocked
	print("Dash Unlocked: ", isUnlocked)

#endregion
