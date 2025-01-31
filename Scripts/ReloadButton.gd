extends TextureButton

func _ready():
	if LevelManager.level == LevelManager.finalLevel:
		texture_normal = load("res://Assets/Reload.png")

func _on_pressed():
	LevelManager.nextLevel(self)
