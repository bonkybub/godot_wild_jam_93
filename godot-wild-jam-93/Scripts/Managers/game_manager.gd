extends Node
# After figuring out how to make a singleton in godot, all player 'upgradeable' plyer values are gonna be stored here
# If we plan on scaling enemy hp, then we should also put it here

#region Player Values / Upgradeables
var player_hp: int = 100
var player_damage: int = 20
var player_speed: int = 5

var player_money: int = 1000

var player_canDash: bool = false
var player_hasScatterShot: bool = false
#endregion

#region Upgrade Costs
var hp_upgrade_cost: int = 100
var damage_upgrade_cost: int = 100
var speed_upgrade_cost: int = 100

var dash_unlock_cost: int = 250
var scattershot_unlock_cost: int = 500

var base_upgrade_cost_multiplier: float = 1.5
#endregion

#region Upgrade Amounts
var hp_upgrade_amount: int = 10
var damage_upgrade_amount: int = 2
var speed_upgrade_amount: int = 1
#endregion


#region Money Functions
func can_afford(cost: int) -> bool:
	return player_money >= cost

func spend_money(cost: int) -> bool:
	if can_afford(cost) == false:
		print("Not enough credits")
		return false

	player_money -= cost
	print("Credits left: ", player_money)
	return true
#endregion


#region Buy upgrades
func buy_health_upgrade() -> bool:
	if spend_money(hp_upgrade_cost) == false:
		return false

	increase_player_health(hp_upgrade_amount)
	hp_upgrade_cost = get_next_upgrade_cost(hp_upgrade_cost)
	return true

func buy_damage_upgrade() -> bool:
	if spend_money(damage_upgrade_cost) == false:
		return false

	increase_player_damage(damage_upgrade_amount)
	damage_upgrade_cost = get_next_upgrade_cost(damage_upgrade_cost)
	return true

func buy_speed_upgrade() -> bool:
	if spend_money(speed_upgrade_cost) == false:
		return false

	increase_player_speed(speed_upgrade_amount)
	speed_upgrade_cost = get_next_upgrade_cost(speed_upgrade_cost)
	return true

func get_next_upgrade_cost(current_cost: int) -> int:
	return roundi(current_cost * base_upgrade_cost_multiplier)

func buy_dash_unlock() -> bool:
	if player_canDash:
		return false

	if spend_money(dash_unlock_cost) == false:
		return false

	unlock_player_dash(true)
	return true

func buy_scattershot_unlock() -> bool:
	if player_hasScatterShot:
		return false

	if spend_money(scattershot_unlock_cost) == false:
		return false

	unlock_player_scattershot(true)
	return true
#endregion


#region Player Upgrade Functions
func increase_player_health(amount: int) -> void:
	player_hp += amount
	print("Player health is now: ", player_hp)

func increase_player_damage(amount: int) -> void:
	player_damage += amount
	print("Player damage is now: ", player_damage)

func increase_player_speed(amount: int) -> void:
	player_speed += amount
	print("Player speed is now: ", player_speed)

func unlock_player_dash(isUnlocked: bool) -> void:
	player_canDash = isUnlocked
	print("Dash Unlocked: ", isUnlocked)

func unlock_player_scattershot(isUnlocked: bool) -> void:
	player_hasScatterShot = isUnlocked
	print("Scattershot Unlocked: ", isUnlocked)
#endregion
