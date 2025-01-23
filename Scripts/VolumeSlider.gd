extends HSlider


func _on_drag_ended(value_changed):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value_changed)
