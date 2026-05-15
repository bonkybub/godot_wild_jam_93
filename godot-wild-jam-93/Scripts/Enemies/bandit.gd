class_name Bandit
extends Enemy

var group: BanditGroup

func death() -> void:
	if group.active_bandits.has(self):
		group.active_bandits.remove_at(group.active_bandits.find(self))
	super()
