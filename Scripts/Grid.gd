class_name Grid
extends Node2D

var grid := []
var width := 20
var height := 20
var tsize := 16
var directions = [
	Vector2i(1,0),	Vector2i(-1,0),	Vector2i(0,1),	Vector2i(0,-1)
]

@onready var tilemap: TileMap = get_node("TileMap")

func _ready():
	for i in range(width):
		grid.append([])
		for j in range(height):
			grid[i].append(Tile.new(i, j))
	grid[10][10].terrain = BasicVine.new(10, 10)

func _process(_delta):
	if Input.is_action_pressed("left_click"):
		var pos = global_to_coord(get_global_mouse_position())
		var canPlace = false
		for d in directions:
			if getTerrain(pos.x+d.x, pos.y+d.y) is Vine:
				canPlace = true
		if canPlace: place(pos.x, pos.y)
	
	# Render tiles:
	for i in range(width):
		for j in range(height):
			tilemap.set_cells_terrain_connect(0, [Vector2i(i,j)], 0, getTerrain(i,j).terrainIndex)

func getTerrain(x:int, y:int) -> Terrain:
	if x >= width or x < 0: return null
	if y >= height or y < 0: return null
	return grid[x][y].terrain

func place(x:int, y:int):
	if x >= width or x < 0: return
	if y >= height or y < 0: return
	grid[x][y].terrain = BasicVine.new(x, y)

func global_to_coord(v: Vector2) -> Vector2i:
	return Vector2i(floor(v.x/tsize), floor(v.y/tsize))
