extends Button


func _on_pressed():
	get_node("/root/MainMenu").queue_free()
	get_tree().root.add_child(load("res://Scenes/Level 1.tscn").instantiate())
