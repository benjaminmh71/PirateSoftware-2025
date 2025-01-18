extends Camera2D

var prevPos: Vector2
var speed := 20

func _ready():
	prevPos = get_global_mouse_position()


func _process(delta):
	if Input.is_action_pressed("right_click"):
		var pos = get_global_mouse_position()
		if (prevPos - pos).length() < speed:
			position += prevPos-pos
		else:
			position += (prevPos-pos).normalized() * speed
	
	prevPos = get_global_mouse_position()
