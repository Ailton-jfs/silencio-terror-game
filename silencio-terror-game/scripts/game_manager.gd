extends Node2D

var monster_scene = preload("res://scenes/monster.tscn")

func _process(delta):

	if NoiseSystem.noise >= 100:
		spawn_monster()

func spawn_monster():
	var monster = monster_scene.instantiate()
	monster.global_position = Vector2(400, 300)
	add_child(monster)
