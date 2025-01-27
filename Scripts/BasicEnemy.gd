class_name BasicEnemy
extends Enemy

@onready var emitter:CPUParticles2D = get_node("Emitter")
@onready var flamethrower = get_node("../../Sounds/Flamethrower")
var is_firing = false
func _ready():
	health = 10
	attackDamage = 1
	speed = 10
	attackRange = 14

func _physics_process(_delta: float) -> void:
	super(_delta)
	if closestVine != null and dist <= attackRange and !attackTimer.is_stopped():
		if (is_firing == false): 
			GlobalSignals.add_flamer.emit()
			is_firing = true	
		emitter.emitting = true
		emitter.direction = grid.coord_to_global(Vector2i(closestVine.x, closestVine.y)) - global_position
	else:
		if (is_firing == true):
			GlobalSignals.destroy_flamer.emit()
			is_firing = false
		emitter.emitting = false
	if (health <= 0) and (is_firing == true):
		GlobalSignals.destroy_flamer.emit()
