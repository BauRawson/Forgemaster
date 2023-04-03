extends Node2D


var character_scene = load("res://scenes/minion.tscn")

var minion_tiers: Array = [
	[load("res://scenes/minion_1.tscn")], # 0 (add 1 to all of these)
	[load("res://scenes/minion_2.tscn")], # 1
	[load("res://scenes/minion_3.tscn")], # 2
	[load("res://scenes/minion_4.tscn")], # 3
	[load("res://scenes/minion_5.tscn")], # 4
	[load("res://scenes/minion_6.tscn")], # 5
]


func spawn_character(tier: int, modifier: float) -> void:
	var minion_scene: PackedScene = minion_tiers[tier][randi() % minion_tiers[tier].size()]
	var character: Character = minion_scene.instance()
	character.health_points += character.health_points * modifier
	character.attack_damage += character.attack_damage * modifier
	
	add_child(character)
	character.global_position.y = rand_range(250, 600)
