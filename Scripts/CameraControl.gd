extends Camera2D

var prevPos: Vector2
var dragSpeed := 20
var keyboardSpeed := 3


func _ready():
	prevPos = get_local_mouse_position()


func _process(_delta):
	if Input.is_action_pressed("right_click"):
		var pos = get_local_mouse_position()
		if (prevPos - pos).length() < dragSpeed:
			position += prevPos-pos
		else:
			position += (prevPos-pos).normalized() * dragSpeed
	
	if Input.is_action_pressed("keyboard_w"):
		position += Vector2.UP * keyboardSpeed
	if Input.is_action_pressed("keyboard_a"):
		position += Vector2.LEFT * keyboardSpeed
	if Input.is_action_pressed("keyboard_s"):
		position += Vector2.DOWN * keyboardSpeed
	if Input.is_action_pressed("keyboard_d"):
		position += Vector2.RIGHT * keyboardSpeed
	
	prevPos = get_local_mouse_position()
