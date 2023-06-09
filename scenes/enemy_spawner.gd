extends Node2D


var character_scene = load("res://scenes/enemy.tscn")


func on_spawn_timer_timeout() -> void:
	spawn_character()


func spawn_character() -> void:
	var character: Character = character_scene.instance()
	
	$Enemies.add_child(character)
	character.global_position.y = rand_range(250, 600)
