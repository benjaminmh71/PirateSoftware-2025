class_name Vine
extends Terrain

var health: float
signal died(vine)

func damage(d):
	health -= d
	if health < 0:
		died.emit(self)
