class_name BasicEnemy
extends Enemy

@onready var emitter:CPUParticles2D = get_node("Emitter")

func _ready():
	health = 10
	attackDamage = 1
	speed = 10
	attackRange = 14

func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if closestVine != null and dist <= attackRange and !attackTimer.is_stopped():
		emitter.emitting = true
		emitter.direction = grid.coord_to_global(Vector2i(closestVine.x, closestVine.y)) - global_position
	else:
		emitter.emitting = false
