extends Node

var level = 0
var finalLevel = 4

func get_local_scene_root(p_node : Node) -> Node:
	while(p_node.get_parent().get_parent() is Node):
		p_node = p_node.get_parent()
		
	return p_node as Node

func reloadLevel(this):
	get_local_scene_root(this).queue_free()
	get_tree().root.add_child(load(getLevelName()).instantiate())

func nextLevel(this):
	if level != finalLevel: level += 1
	get_local_scene_root(this).queue_free()
	get_tree().root.add_child(load(getLevelName()).instantiate())

func getLevelName():
	if level == 0: return "res://Scenes/Tutorial.tscn"
	return "res://Scenes/Level " + str(level) + ".tscn"
