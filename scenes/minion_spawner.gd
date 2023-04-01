extends Node2D


var character_scene = load("res://scenes/minion.tscn")


func spawn_character() -> void:
	var character: Character = character_scene.instance()
	
	add_child(character)
