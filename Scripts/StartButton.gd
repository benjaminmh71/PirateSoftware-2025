extends TextureButton


func _on_pressed():
	LevelManager.reloadLevel(self)
