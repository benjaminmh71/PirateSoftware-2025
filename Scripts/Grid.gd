class_name Grid
extends Node2D

var grid := []
@export var width := 45
@export var height := 45
var tsize := 16
var directions := [
	Vector2i(1,0),	Vector2i(-1,0),	Vector2i(0,1),	Vector2i(0,-1)
]
var snapRange := 3
var vines: Dictionary
var astar := AStarGrid2D.new()
var hydrants := 0
var controlledHydrants := 0

#Water
@onready var WaterTimer = $WaterTimer
var WaterRate = 0.5
var hydrantRateChange = 0.25
var WaterAmount = 15

@onready var tilemap: TileMap = get_node("TileMap")
@onready var fogmap: TileMap = get_node("Fog")
@onready var tilePlacementIndicator: Sprite2D = get_node("TilePlacementIndicator")
@onready var hud:HUD = get_node("UI")
@onready var waterLabel = hud.get_node("VBoxContainer").get_node("WaterLabel")
@onready var waterSourceLabel = hud.get_node("VBoxContainer").get_node("HBoxContainer").get_node("WaterSourceLabel")

func _ready():
	for i in range(width):
		grid.append([])
		for j in range(height):
			grid[i].append(Tile.new(i, j))
	
	# Initialize fog:
	fogmap.visible = true
	
	# Initialize walls:
	for i in range(width):
		for j in range(height):
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) == 3:
				place(i, j, Wall)
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) == 5:
				place(i, j, Roof)
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) == 9:
				place(i, j, Fence)
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) == 1:
				place(i, j, BasicVine)
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) == 2:
				place(i, j, Heart)
				updateFog(Vector2i(i, j))
	
	# Initialize pathfinder:
	astar.region = Rect2i(0, 0, width, height)
	astar.cell_size = Vector2i(tsize, tsize)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for i in range(width):
		for j in range(height):
			if getTerrain(i, j).impassable:
				astar.set_point_solid(Vector2i(i, j))
			else:
				for d in directions:
					if getTerrain(i+d.x, j+d.y).impassable:
						astar.set_point_weight_scale(Vector2i(i, j), 1.2)
	
	# Initialize hydrants:
	for h in get_node("Hydrants").get_children():
		var pos = global_to_coord(h.global_position)
		getTile(pos.x, pos.y).hasHydrant = true
		hydrants += 1

func _process(_delta):
	waterLabel.text = "Water: " + str(floor(WaterAmount))
	waterSourceLabel.text = ": " + str(controlledHydrants)+"/"+str(hydrants)
	
	# Render tile placement indicator:
	var pos = global_to_coord(get_global_mouse_position())
	var closestValidPos = getClosestValidTile(pos)
	if closestValidPos != null and !(getTerrain(pos.x, pos.y) is Vine or 
		getTerrain(closestValidPos.x, closestValidPos.y).impassable):
		tilePlacementIndicator.visible = true
		tilePlacementIndicator.position = coord_to_global(closestValidPos)
		if Input.is_action_pressed("left_click"):
			place(closestValidPos.x, closestValidPos.y, hud.selected)
	else:
		tilePlacementIndicator.visible = false
	# Render tiles:
	for i in range(width):
		for j in range(height):
			if BetterTerrain.get_cell(tilemap, 0, Vector2i(i,j)) != getTerrain(i, j).terrainIndex:
				BetterTerrain.set_cell(tilemap, 0, Vector2i(i, j), getTerrain(i,j).terrainIndex)
				BetterTerrain.update_terrain_cell(tilemap, 0, Vector2i(i, j))
	

func updateFog(pos: Vector2i, deadVine = null):
	if getTerrain(pos.x, pos.y) is Vine:
		var v = getTerrain(pos.x, pos.y)
		for i in range(-v.fogReveal, v.fogReveal+1):
			for j in range(-v.fogReveal, v.fogReveal+1):
				if Vector2i(i, j).length() > v.fogReveal: continue
				var tile = getTile(pos.x+i, pos.y+j)
				if tile == null: continue
				tile.revealVines.push_back(v)
				if !tile.poisonPlants.is_empty(): continue
				BetterTerrain.set_cell(fogmap, 0, Vector2i(v.x+i, v.y+j), -1)
				BetterTerrain.update_terrain_cell(fogmap, 0, Vector2i(v.x+i, v.y+j))
	else:
		for i in range(-deadVine.fogReveal, deadVine.fogReveal+1):
			for j in range(-deadVine.fogReveal, deadVine.fogReveal+1):
				var tile = getTile(pos.x+i, pos.y+j)
				if tile == null: continue
				tile.revealVines.erase(deadVine)
				if (tile.revealVines.is_empty()):
					BetterTerrain.set_cell(fogmap, 0, Vector2i(pos.x+i, pos.y+j), 0)
					BetterTerrain.update_terrain_cell(fogmap, 0, Vector2i(pos.x+i, pos.y+j))

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
	if x >= width or x < 0: return Wall.new(x,y)
	if y >= height or y < 0: return Wall.new(x,y)
	return grid[x][y].terrain

func getTile(x:int, y:int) -> Tile:
	if x >= width or x < 0: return null
	if y >= height or y < 0: return null
	return grid[x][y]

func place(x:int, y:int, terrainClass):
	if x >= width or x < 0: return
	if y >= height or y < 0: return
	var terrain = terrainClass.new(x, y)
	if terrain is Vine:
		if WaterAmount < terrain.cost: return 
	grid[x][y].terrain = terrain
	if terrain is Vine:
		vines[terrain] = true
		terrain.died.connect(onVineDeath)
		updateFog(Vector2i(x, y))
		WaterAmount -= terrain.cost
		if grid[x][y].hasHydrant:
			controlledHydrants += 1
			if controlledHydrants >= hydrants:
				self.queue_free()
				get_tree().root.add_child(load("res://Scenes/WinScreen.tscn").instantiate())
		if terrain is PoisonPlant:
			for i in range(-1, 2):
				for j in range(-1, 2):
					var tile = getTile(x+i, y+j)
					if tile == null: continue
					tile.poisonPlants.push_back(terrain)
					BetterTerrain.set_cell(fogmap, 0, Vector2i(x+i, y+j), 1)
					BetterTerrain.update_terrain_cell(fogmap, 0, Vector2i(x+i, y+j))

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
		
		if grid[vine.x][vine.y].hasHydrant:
			controlledHydrants -= 1
		
		if vine is PoisonPlant:
			for i in range(-1, 2):
				for j in range(-1, 2):
					var tile = getTile(vine.x+i, vine.y+j)
					if tile == null: continue
					tile.poisonPlants.erase(vine)
					if (tile.poisonPlants.is_empty()):
						BetterTerrain.set_cell(fogmap, 0, Vector2i(vine.x+i, vine.y+j), -1)
						BetterTerrain.update_terrain_cell(fogmap, 0, Vector2i(vine.x+i, vine.y+j))
		updateFog(Vector2i(vine.x, vine.y), vine)

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


func _on_water_timer_timeout():
	WaterAmount += WaterRate + hydrantRateChange * controlledHydrants
