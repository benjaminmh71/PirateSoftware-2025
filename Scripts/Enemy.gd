class_name Enemy
extends CharacterBody2D

@onready var grid: Grid = get_parent().get_parent()
@onready var attackTimer: Timer = get_node("AttackTimer")
@onready var constrictTimer: Timer = get_node("ConstrictTimer")

var health: float
var attackDamage: float
var speed: float
var attackRange: float
var constrictDist = 12


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
	
	# Constriction:
	if dist <= constrictDist and constrictTimer.is_stopped():
		damage(closestVine.constrictDamage)
		constrictTimer.start()
	
	# Attacking:
	if closestVine != null and dist <= attackRange and attackTimer.is_stopped():
		closestVine.damage(attackDamage)
		attackTimer.start()

func damage(d: float):
	health -= d
	if health <= 0:
		queue_free()
