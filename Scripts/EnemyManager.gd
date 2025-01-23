class_name EnemyManager
extends Node2D

@onready var waveTimer = get_node("WaveTimer")
var waves = []

var random = RandomNumberGenerator.new()
var count = 1

func _ready():
	for n in get_children():
		if n is Wave:
			waves.push_back(n)

func _on_wave_timer_timeout():
	var wave:Wave = waves.pick_random()
	for e in wave.initial:
		var newEnemy = load(e).instantiate()
		add_child(newEnemy)
		newEnemy.global_position = Vector2(48 + random.randf()*20, 48 + random.randf()*20)
	for i in range(count):
		var newEnemy = load(wave.change[i%wave.change.size()]).instantiate()
		add_child(newEnemy)
		newEnemy.global_position = Vector2(48 + random.randf()*20, 48 + random.randf()*20)
	count += 1
