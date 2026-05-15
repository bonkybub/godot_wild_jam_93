class_name Bandit
extends Enemy

var group: BanditGroup

enum STATE
{
	FLY_IN,
	IDLE,
	STRAFE,
	FLY_OUT
}

func death() -> void:
	if group.active_bandits.has(self):
		group.active_bandits.remove_at(group.active_bandits.find(self))
	super()
