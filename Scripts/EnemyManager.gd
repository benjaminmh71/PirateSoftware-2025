class_name EnemyManager
extends Node2D

@onready var waveTimer = get_node("WaveTimer")
var waves = []
var spawnPoints = []

var random = RandomNumberGenerator.new()
var count = 0

func _ready():
	for n in get_children():
		if n is Wave:
			waves.push_back(n)
		if n.name.begins_with("SpawnPoint"):
			spawnPoints.push_back(n)

func _on_wave_timer_timeout():
	var wave:Wave = waves.pick_random()
	var spawnPoint = spawnPoints.pick_random().global_position
	for e in wave.initial:
		var newEnemy = load(e).instantiate()
		add_child(newEnemy)
		newEnemy.global_position = spawnPoint + Vector2((random.randf()-0.5)*32, (random.randf()-0.5)*32)
	for i in range(count):
		if wave.change[i%wave.change.size()] == "": continue
		var newEnemy = load(wave.change[i%wave.change.size()]).instantiate()
		add_child(newEnemy)
		newEnemy.global_position = spawnPoint + Vector2((random.randf()-0.5)*32, (random.randf()-0.5)*32)
	count += 1
