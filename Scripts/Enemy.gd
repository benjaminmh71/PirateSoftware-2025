class_name Enemy
extends CharacterBody2D

@onready var grid: Grid = get_parent().get_parent()
@onready var attackTimer: Timer = get_node("AttackTimer")

var health: float
var damage: float
var speed: float
var attackRange: float

func _ready():
	pass # Replace with function body.


func _process(_delta):
	# Movement:
	var closestVine = null
	var dist = INF
	for v in grid.vines.keys():
		var length = (global_position - grid.coord_to_global(Vector2i(v.x, v.y))).length()
		if length < dist:
			closestVine = v
			dist = length
	if closestVine != null and dist > attackRange:
		var target = grid.coord_to_global(Vector2i(closestVine.x, closestVine.y))
		velocity = (target - global_position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# Attacking:
	if closestVine != null and dist <= attackRange and attackTimer.is_stopped():
		closestVine.damage(damage)
		attackTimer.start()
