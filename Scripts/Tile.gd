class_name Tile
extends Object

var x:int
var y:int
var terrain: Terrain
var revealVines:Array = []
var poisonPlants:Array = []
var hasHydrant = false

func _init(_x:int, _y:int):
	x = _x
	y = _y
	terrain = Empty.new(x, y)
