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
	place(5, 5, Heart)

func _process(_delta):
	# Render tile placement indicator:
	var pos = global_to_coord(get_global_mouse_position())
	var closestValidPos = getClosestValidTile(pos)
	if closestValidPos != null and !(getTerrain(pos.x, pos.y) is Vine):
		tilePlacementIndicator.visible = true
		tilePlacementIndicator.position = coord_to_global(closestValidPos)
		if Input.is_action_pressed("left_click"):
			place(closestValidPos.x, closestValidPos.y, BasicVine)
	else:
		tilePlacementIndicator.visible = false
	
	# Render tiles:
	for i in range(width):
		for j in range(height):
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) != getTerrain(i, j).terrainIndex:
				BetterTerrain.set_cell(tilemap, 0, Vector2i(i, j), getTerrain(i,j).terrainIndex)
				BetterTerrain.update_terrain_cell(tilemap, 0, Vector2i(i, j))

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

func place(x:int, y:int, vineClass):
	if x >= width or x < 0: return
	if y >= height or y < 0: return
	grid[x][y].terrain = vineClass.new(x, y)
	vines[grid[x][y].terrain] = true
	grid[x][y].terrain.died.connect(onVineDeath)

func onVineDeath(vine: Vine):
	grid[vine.x][vine.y].terrain = Empty.new(vine.x, vine.y)
	vines.erase(vine)
	if vine is Heart:
		self.queue_free()
		get_tree().root.add_child(load("res://Scenes/LoseScreen.tscn").instantiate())
	else:
		var vineArray = []
		var toDestroy = []
		
		for v in vines.keys():
			vineArray.push_back(v)
		
		for d in directions:
			var checkVine = getTerrain(vine.x+d.x, vine.y+d.y)
			if !(checkVine is Vine): continue
			if !check_connection(vineArray, checkVine):
				toDestroy.append(checkVine)
		
		for v in toDestroy:
			massDestroy(v)

func check_connection(tiles, start) -> bool:
	if not tiles:
		return false
	
	var checked = [] #sets are not in godot yet :c
	var stack = [start]

	while stack:
		var current_tile = stack.pop_back()
		if current_tile in checked:
			continue
		checked.push_back(current_tile)
		
		if current_tile is Heart:
			return true
		
		#check orthogonals here
		var neighbours = [
		getTerrain(current_tile.x + 1, current_tile.y),  
		getTerrain(current_tile.x - 1, current_tile.y), 
		getTerrain(current_tile.x, current_tile.y + 1), 
		getTerrain(current_tile.x, current_tile.y - 1)
		]
		
		for neighbour in neighbours:
			if neighbour in tiles and neighbour not in checked:
				stack.push_back(neighbour)
	
	return false

func massDestroy(vine: Vine):
	vine.damage(999)
	for d in directions:
		if getTerrain(vine.x+d.x, vine.y+d.y) is Vine:
			massDestroy(getTerrain(vine.x+d.x, vine.y+d.y))

func global_to_coord(v: Vector2) -> Vector2i:
	return Vector2i(floor(v.x/tsize), floor(v.y/tsize))

func coord_to_global(v: Vector2i) -> Vector2:
	return Vector2(v.x*tsize+tsize/2, v.y*tsize+tsize/2)
