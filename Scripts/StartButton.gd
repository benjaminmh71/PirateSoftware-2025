extends Button


func _on_pressed():
	LevelManager.reloadLevel(self)
