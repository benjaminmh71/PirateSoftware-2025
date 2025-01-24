extends Camera2D

var prevPos: Vector2
var dragSpeed := 20
var keyboardSpeed := 3
var zoomFactor = 1
var attackingEnemies = []

@onready var grid: Grid = get_parent()
@onready var warning: TextureRect = grid.get_node("UI/WarningIndicator")
@onready var heart = get_parent().get_node("Heart")

func _ready():
	position_smoothing_enabled = false
	global_position = heart.global_position
	prevPos = get_local_mouse_position()


func _process(_delta):
	position_smoothing_enabled = true
	
	if Input.is_action_just_released("scroll_forward") and zoom.x < 2:
		zoomFactor += 0.1
	if Input.is_action_just_released("scroll_backward") and zoom.x > 0.5:
		zoomFactor -= 0.1
	zoom = Vector2(zoomFactor, zoomFactor)
	var invertedZoom = 1/zoomFactor
	
	var size = get_viewport_rect().size
	
	# Enemy offscreen warning:
	var closestEnemy = null
	var closestDist = INF
	for e in attackingEnemies:
		if !is_instance_valid(e): continue
		var pos = e.global_position
		if ((pos - global_position).length() < closestDist
			and (pos.x < global_position.x - size.x/2 * invertedZoom 
			or pos.x > global_position.x + size.x/2 * invertedZoom
			or pos.y < global_position.y - size.y/2 * invertedZoom 
			or pos.y > global_position.y + size.y/2 * invertedZoom)):
			closestEnemy = e
			closestDist = (e.global_position - global_position).length()
	
	if closestEnemy != null:
		warning.visible = true
		var dir = (closestEnemy.global_position - global_position).normalized()
		warning.anchor_left = dir.x * 0.4 + 0.5
		warning.anchor_right = dir.x * 0.4 + 0.5
		warning.anchor_top = dir.y * 0.4 + 0.5
		warning.anchor_bottom = dir.y * 0.4 + 0.5
	else:
		warning.visible = false
	
	if Input.is_action_pressed("right_click"):
		var pos = get_local_mouse_position()
		if (prevPos - pos).length() < dragSpeed * invertedZoom:
			position += prevPos-pos
		else:
			position += (prevPos-pos).normalized() * dragSpeed * invertedZoom
	
	if Input.is_action_pressed("keyboard_w"):
		position += Vector2.UP * keyboardSpeed * invertedZoom
	if Input.is_action_pressed("keyboard_a"):
		position += Vector2.LEFT * keyboardSpeed * invertedZoom
	if Input.is_action_pressed("keyboard_s"):
		position += Vector2.DOWN * keyboardSpeed * invertedZoom
	if Input.is_action_pressed("keyboard_d"):
		position += Vector2.RIGHT * keyboardSpeed * invertedZoom
	
	if global_position.x < size.x/2 * invertedZoom:
		global_position.x = size.x/2 * invertedZoom
	if global_position.y < size.y/2 * invertedZoom:
		global_position.y = size.y/2 * invertedZoom
	if global_position.x > grid.width * grid.tsize - size.x/2 * invertedZoom:
		global_position.x = grid.width * grid.tsize - size.x/2 * invertedZoom
	if global_position.y > grid.height * grid.tsize - size.y/2 * invertedZoom:
		global_position.y = grid.height * grid.tsize - size.y/2 * invertedZoom
	
	prevPos = get_local_mouse_position()
	attackingEnemies = []
