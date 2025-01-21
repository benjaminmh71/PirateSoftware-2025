class_name HUD
extends CanvasLayer

var selected = BasicVine
var index = 0

@onready var basicVineIndicator = get_node("HBoxContainer/BasicVine/Indicator")
@onready var thickVineIndicator = get_node("HBoxContainer/ThickVine/Indicator")
@onready var eyePlantIndicator = get_node("HBoxContainer/EyePlant/Indicator")

func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_pressed("ui_1"):
		index = 0
	if Input.is_action_pressed("ui_2"):
		index = 1
	if Input.is_action_pressed("ui_3"):
		index = 2
	
	if index == 0:
		selected = BasicVine
		resetIndicators()
		basicVineIndicator.visible = true
	if index == 1:
		selected = ThickVine
		resetIndicators()
		thickVineIndicator.visible = true
	if index == 2:
		selected = EyePlant
		resetIndicators()
		eyePlantIndicator.visible = true

func resetIndicators():
	basicVineIndicator.visible = false
	thickVineIndicator.visible = false
	eyePlantIndicator.visible = false
