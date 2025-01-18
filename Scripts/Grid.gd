class_name Grid
extends Node2D

var grid := []
var width := 20
var height := 20
var tsize := 16
var directions := [
	Vector2i(1,0),	Vector2i(-1,0),	Vector2i(0,1),	Vector2i(0,-1)
]
var snapRange := 3
var vines: Dictionary

@onready var tilemap: TileMap = get_node("TileMap")
@onready var tilePlacementIndicator: Sprite2D = get_node("TilePlacementIndicator")

func _ready():
	for i in range(width):
		grid.append([])
		for j in range(height):
			grid[i].append(Tile.new(i, j))
	place(5, 5)

func _process(_delta):
	# Render tile placement indicator:
	var pos = global_to_coord(get_global_mouse_position())
	var closestValidPos = getClosestValidTile(pos)
	if closestValidPos != null and !(getTerrain(pos.x, pos.y) is Vine):
		tilePlacementIndicator.visible = true
		tilePlacementIndicator.position = coord_to_global(closestValidPos)
		if Input.is_action_pressed("left_click"):
			place(closestValidPos.x, closestValidPos.y)
	else:
		tilePlacementIndicator.visible = false
	
	# Render tiles:
	for i in range(width):
		for j in range(height):
			tilemap.set_cells_terrain_connect(0, [Vector2i(i,j)], 0, getTerrain(i,j).terrainIndex)

func getClosestValidTile(pos: Vector2i):
	var closestValidPos = null
	var closestDist = INF
	for d in directions:
		for r in range(1, snapRange+1):
			if getTerrain(pos.x+d.x*r, pos.y+d.y*r) is Vine and r < closestDist:
				closestValidPos = pos+d*(r-1)
				closestDist = r
	return closestValidPos

func getTerrain(x:int, y:int) -> Terrain:
	if x >= width or x < 0: return null
	if y >= height or y < 0: return null
	return grid[x][y].terrain

func place(x:int, y:int):
	if x >= width or x < 0: return
	if y >= height or y < 0: return
	grid[x][y].terrain = BasicVine.new(x, y)
	vines[grid[x][y].terrain] = true
	grid[x][y].terrain.died.connect(onVineDeath)

func onVineDeath(vine: Vine):
	grid[vine.x][vine.y].terrain = Empty.new(vine.x, vine.y)
	vines.erase(vine)

func global_to_coord(v: Vector2) -> Vector2i:
	return Vector2i(floor(v.x/tsize), floor(v.y/tsize))

func coord_to_global(v: Vector2i) -> Vector2:
	return Vector2(v.x*tsize+tsize/2, v.y*tsize+tsize/2)
