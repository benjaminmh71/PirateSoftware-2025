extends NinePatchRect

@onready var label = get_node("Label")
@onready var grid: Grid = get_parent().get_parent()
var index = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if index == 0:
		label.text = "Your vines can't see very far normally. Press 3 and place an eye vine to reveal the level."
		for v in grid.vines:
			if v is EyePlant:
				index += 1
				break
	
	if index == 1:
		label.text = "Those are enemies up north. Grow out your vines to entangle and kill them."
		var enemies = grid.get_node("EnemyManager").get_children()
		var are_enemies = false
		for e in enemies:
			if e is Enemy: are_enemies = true
		if !are_enemies: index += 1
	
	if index == 2:
		label.text = "Great! Now grow your vines over that fire hydrant to win the level."
