extends Button

func _ready():
	if LevelManager.level == LevelManager.finalLevel:
		text = "Reload"

func _on_pressed():
	LevelManager.nextLevel(self)
