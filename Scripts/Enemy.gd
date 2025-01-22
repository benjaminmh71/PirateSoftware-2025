class_name Enemy
extends CharacterBody2D

@onready var grid: Grid = get_parent().get_parent()
@onready var sprite = get_node("AnimatedSprite2D")
@onready var attackTimer: Timer = get_node("AttackTimer")
@onready var constrictTimer: Timer = get_node("ConstrictTimer")
@onready var poisonTimer: Timer = get_node("PoisonTimer")
@onready var navTimer: Timer = get_node("NavTimer")

var health: float
var attackDamage: float
var speed: float
var attackRange: float
var constrictDist := 12
var standAnimation := "stand_down"
var path = []
var pathIndex = 1
var closestVine = null
var dist = INF

func _process(_delta):
	# Poison:
	var tile = grid.getTile(grid.global_to_coord(global_position).x, grid.global_to_coord(global_position).y)
	var speedFactor = 1 # For poison slow
	if tile != null:
		if !tile.poisonPlants.is_empty():
			speedFactor = PoisonPlant.poisonSlow
			if poisonTimer.is_stopped():
				damage(PoisonPlant.poisonDamage)
				poisonTimer.start()
	
	# Movement:
	closestVine = null
	dist = INF
	for v in grid.vines.keys():
		var length = (global_position - grid.coord_to_global(Vector2i(v.x, v.y))).length()
		if length < dist:
			closestVine = v
			dist = length
	if closestVine != null and dist > attackRange:
		if navTimer.is_stopped():
			path = grid.astar.get_point_path(grid.global_to_coord(position), Vector2i(closestVine.x, closestVine.y))
			pathIndex = 1
			navTimer.start()
		if path.size() == 1: pathIndex = 0
		if ((global_position - (path[pathIndex] + Vector2(8, 8))).length() < 8
			and pathIndex < path.size()-1):
				pathIndex += 1
		var target = path[pathIndex] + Vector2(8, 8)
		velocity = (target - global_position).normalized() * speed * speedFactor
	else:
		velocity = Vector2.ZERO
	
	if abs(velocity.x) > abs(velocity.y) and velocity.x > 0:
		sprite.play("walk_right")
		standAnimation = "stand_right"
	elif abs(velocity.x) > abs(velocity.y) and velocity.x < 0:
		sprite.play("walk_left")
		standAnimation = "stand_left"
	elif abs(velocity.x) < abs(velocity.y) and velocity.y > 0:
		sprite.play("walk_down")
		standAnimation = "stand_down"
	elif abs(velocity.x) < abs(velocity.y) and velocity.y < 0:
		sprite.play("walk_up")
		standAnimation = "stand_up"
	else:
		sprite.play(standAnimation)
	
	move_and_slide()
	
	# Constriction:
	if dist <= constrictDist and constrictTimer.is_stopped():
		damage(closestVine.constrictDamage)
		constrictTimer.start()
	
	# Attacking:
	if closestVine != null and dist <= attackRange and attackTimer.is_stopped():
		closestVine.damage(attackDamage)
		damage(closestVine.thorns)
		attackTimer.start()

func damage(d: float):
	health -= d
	if health <= 0:
		queue_free()
