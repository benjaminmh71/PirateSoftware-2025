extends Button


func _on_pressed():
	get_node("/root/OptionsMenu").queue_free()
	get_tree().root.add_child(load("res://Scenes/MainMenu.tscn").instantiate())
