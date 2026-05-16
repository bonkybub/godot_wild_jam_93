class_name Bandit
extends Enemy

var group: BanditGroup

func death() -> void:
	if group.active_bandits.has(self):
		group.active_bandits.remove_at(group.active_bandits.find(self))
	if group.bandits_to_shoot.has(self):
		group.bandits_to_shoot.remove_at(group.bandits_to_shoot.find(self))
	super()
	
	GameManager.player_money += 50 
