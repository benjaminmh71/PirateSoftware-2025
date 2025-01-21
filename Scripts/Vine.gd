class_name Vine
extends Terrain

var health: float
var constrictDamage: float
var fogReveal := 2.5
var cost: int
var thorns := 0.0
signal died(vine)

func damage(d):
	health -= d
	if health <= 0:
		died.emit(self)
