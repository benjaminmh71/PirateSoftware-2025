class_name PoisonPlant
extends Vine

static var poisonDamage = 0.25
static var poisonSlow = 0.5

func _init(_x, _y):
	super(_x, _y)
	terrainIndex = 8
	health = 5
	constrictDamage = 0.5
	cost = 2
