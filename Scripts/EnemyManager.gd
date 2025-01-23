class_name EnemyManager
extends Node2D

@onready var waveTimer = get_node("WaveTimer")

@export var enemy: Enemy

var random = RandomNumberGenerator.new()
var count = 1

func _on_wave_timer_timeout():
	for i in range(count):
		var newEnemy = load("res://Enemies/Basic Enemy.tscn").instantiate()
		add_child(newEnemy)
		newEnemy.global_position = Vector2(48 + random.randf()*20, 48 + random.randf()*20)
	count += 1
