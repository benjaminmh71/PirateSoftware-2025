class_name HUD
extends CanvasLayer

var selected = BasicVine
var index = 0

@onready var basicVineIndicator = get_node("HBoxContainer/BasicVine/Indicator")
@onready var thickVineIndicator = get_node("HBoxContainer/ThickVine/Indicator")
@onready var eyePlantIndicator = get_node("HBoxContainer/EyePlant/Indicator")
@onready var poisonPlantIndicator = get_node("HBoxContainer/PoisonPlant/Indicator")
@onready var playPauseButton = get_node("PauseButtonMargins/VBoxContainer/PauseButton")
@onready var clickSound = get_node("../Sounds/Click")
@onready var waterSourceRect: TextureRect = get_node("VBoxContainer/HBoxContainer/TextureRect")
@onready var resetConfirmation = get_node("ResetConfirmation")
var playButtonTextureArray = [load("res://Assets/PauseButton.png"),load("res://Assets/PlayButton.png")]
var playButtonBool = true

@export var waterSourceTexture = "res://Assets/fireHydrent.webp"

func _ready():
	waterSourceRect.texture = load(waterSourceTexture)


func _process(delta):
	if Input.is_action_pressed("ui_1"):
		index = 0
	if Input.is_action_pressed("ui_2"):
		index = 1
	if Input.is_action_pressed("ui_3"):
		index = 2
	if Input.is_action_pressed("ui_4"):
		index = 3
	
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
	if index == 3:
		selected = PoisonPlant
		resetIndicators()
		poisonPlantIndicator.visible = true

func resetIndicators():
	basicVineIndicator.visible = false
	thickVineIndicator.visible = false
	eyePlantIndicator.visible = false
	poisonPlantIndicator.visible = false

func _on_basic_button_pressed():
	index = 0
	
func _on_thick_button_pressed():
	index = 1
	
func _on_eye_button_pressed():
	index = 2
	
func _on_poison_button_pressed():
	index = 3

func _on_pause_button_pressed():
	if playButtonBool == true:
		playPauseButton.texture_normal = playButtonTextureArray[1]
		playButtonBool = !playButtonBool
		clickSound.play()
		get_tree().paused = true
	elif playButtonBool == false:
		playPauseButton.texture_normal = playButtonTextureArray[0]
		playButtonBool = !playButtonBool
		clickSound.play()
		get_tree().paused = false


func _on_reset_button_pressed():
	resetConfirmation.visible = true


func _on_yes_button_pressed():
	LevelManager.reloadLevel(self)


func _on_no_button_pressed():
	resetConfirmation.visible = false
