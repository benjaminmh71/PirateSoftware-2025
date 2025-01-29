class_name GunEnemy
extends Enemy

func _ready():
	health = 20
	attackDamage = 1
	speed = 10
	attackRange = 48
	ranged = true

func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if attackTimer.time_left > 0.9:
		sprite.play("shoot_" + standAnimation.substr(6))
