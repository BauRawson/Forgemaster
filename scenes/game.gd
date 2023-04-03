extends Node2D

signal tutorial
signal tutorial_2

var current_level: int = 1

var active_rune: String = ""
var current_letter_index: int = 0
var current_rune_index: int = 0
var runes: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

onready var current_rune_label: RichTextLabel = $"%CurrentRuneRichTextLabel"

export var blue: Color = Color.blue
export var green: Color = Color.green
export var red: Color = Color.red # 8383a6

var rune_names: Array = [
	"erebos",
	"ishtar",
	"algiz",
	"nauthiz",
	"thurisaz",
	"ansuz",
	"kaos",
	"eihwaz",
	"aegir",
	"draugr"
]

var tutorial_0: String = "Type the word inside the circle to charge a rune"
var tutorial_1: String = "once all runes have been charged, press enter to summon a minion. the fuller the circle, the stronger the minion."

func _ready():
	get_new_rune_set()
	$PlayerBase.connect("died", self, "on_player_base_died")
	$EnemyBase.connect("died", self, "on_enemy_base_died")
	
	$CanvasLayer/Tutorial.show()
	
	connect("tutorial", self, "advance_tutorial")
	get_tree().paused = true


func advance_tutorial() -> void:
	print("HOLA")
	disconnect("tutorial", self, "advance_tutorial")
	connect("tutorial_2", self, "finish_tutorial")
	$CanvasLayer/Tutorial/Label.text = tutorial_1


func finish_tutorial() -> void:
	disconnect("tutorial", self, "finish_tutorial")
	$CanvasLayer/Tutorial.hide()
	get_tree().paused = false


func on_player_base_died() -> void:
	current_level = 1
	$CanvasLayer/GameOver/GameOverLabel.text = "You lost!"
	$CanvasLayer/GameOver/PlayAgainButton.connect("pressed", self, "restart_game", [current_level])
	$CanvasLayer/GameOver/PlayAgainButton.text = "TRY AGAIN"
	
	$CanvasLayer/GameOver.show()
	$EnemySpawner/SpawnTimer.stop()


func on_enemy_base_died() -> void:
	current_level += 1
	$CanvasLayer/GameOver/GameOverLabel.text = "You win!"
	$CanvasLayer/GameOver/PlayAgainButton.connect("pressed", self, "restart_game", [current_level])
	$CanvasLayer/GameOver/PlayAgainButton.text = "NEXT LEVEL"
	
	$CanvasLayer/GameOver.show()
	$EnemySpawner/SpawnTimer.stop()


func restart_game(level: int) -> void:
	if level == 1:
		get_tree().reload_current_scene()
	else:
		# delete minions
		for minion in $MinionSpawner.get_children():
			minion.queue_free()
		
		# delete enemies
		for enemy in $EnemySpawner/Enemies.get_children():
			enemy.queue_free()
		
		# restore players base hp
		$PlayerBase.health_points = 120
		
		# create new enemy base
		var enemy_base = load("res://scenes/enemy_base.tscn").instance()
		add_child(enemy_base)
		enemy_base.global_position = Vector2(1153, 400)
		enemy_base.connect("died", self, "on_enemy_base_died")
		
		# update enemy spawner cooldown
		$EnemySpawner/SpawnTimer.wait_time = $EnemySpawner/SpawnTimer.wait_time - 0.25
		$EnemySpawner/SpawnTimer.start()
		# udpate level label
		$CanvasLayer/LevelLabel.text = "Level " + str(current_level)
		$CanvasLayer/GameOver.hide()
		get_new_rune_set()


func _unhandled_input(event: InputEvent) -> void:
	OS.set_ime_active(false)
	if event is InputEventKey and event.is_pressed():
		var typed_event: InputEventKey = event
		
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		print(key_typed.to_lower())
		
		print(current_letter_index)
		var next_character: String = active_rune.substr(current_letter_index, 1)
		
		if key_typed.to_lower() == next_character:
			print("success")
			current_letter_index += 1
			set_next_character(current_letter_index)
			
			if current_letter_index == active_rune.length():
				print("word completed")
				emit_signal("tutorial")
				current_letter_index = 0
				$CanvasLayer/Forge/ForgeCircle.get_child(current_rune_index).get_node("FireParticles").emitting = true
				
				if runes.size() - 1 == current_rune_index:
					$CanvasLayer/Forge/AnimationPlayer.play("activate")
				else:
					current_rune_index += 1
					active_rune = runes[current_rune_index]
					current_rune_label.bbcode_text = "[center]"+ active_rune +"[/center]"
		else: # incorrectly typed.
			print("not success")
		
		if event.scancode == KEY_ENTER:
			# check if activate circle was animated
			# stop animation, get scale values
			# reset animation
			# spawn ally
			if $CanvasLayer/Forge/AnimationPlayer.is_playing():
				print($CanvasLayer/Forge/ActivateCircle.rect_scale)
				$CanvasLayer/Forge/AnimationPlayer.stop()
				$CanvasLayer/Forge/AnimationPlayer.play("RESET")
				spawn_ally(current_rune_index, $CanvasLayer/Forge/ActivateCircle.rect_scale.x)
				current_rune_index = 0
				get_new_rune_set()


func find_new_active_rune(typed_character: String) -> void:
	var prompt: String = "lorem"
	
	var next_character: String = prompt.substr(0, 1)
	print(typed_character)
	print(next_character)
	if typed_character == next_character:
		current_letter_index = 1
		set_next_character(current_letter_index)
		active_rune = prompt


func get_new_rune_set() -> void:
	for rune_complete_icon in $CanvasLayer/Forge/ForgeCircle.get_children():
		rune_complete_icon.queue_free()
	
	runes.clear()
	current_letter_index = 0
	current_rune_index = 0
	
	rng.randomize()
	
	var tier: int = rng.randi_range(1, 6)
	var icon_position_angle: float = 360 / tier
	
	for i in range(tier):
		var random_rune_name: String = rune_names[randi() % rune_names.size()]
		
		while random_rune_name in runes:
			random_rune_name = rune_names[randi() % rune_names.size()]
		
		runes.append(random_rune_name)
		var rune_complete_icon = load("res://scenes/rune_complete_icon.tscn").instance()
		$CanvasLayer/Forge/ForgeCircle.add_child(rune_complete_icon)
		rune_complete_icon.rect_rotation = i * icon_position_angle
		
	active_rune = runes[current_rune_index]
	current_rune_label.bbcode_text = "[center]"+ active_rune +"[/center]"
	
	# Get a random number, from 1 to 6
	# Fill an array with runes, using the amount of the number
	# Runes shouldn't repeat
	# Set rune as 'current_rune'
	# Fill ForgeCircle with rune_complete_icons


func set_next_character(next_character_index: int) -> void:
	var blue_text = get_bbcode_color_tag(blue) + current_rune_label.text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	var green_text = get_bbcode_color_tag(green) + current_rune_label.text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	
	var red_text = ""
	if next_character_index != current_rune_label.text.length():
		red_text = get_bbcode_color_tag(red) + current_rune_label.text.substr(next_character_index + 1, current_rune_label.text.length() - next_character_index + 1) + get_bbcode_end_color_tag()
	
	current_rune_label.parse_bbcode("[center]" + blue_text + green_text + red_text + "[/center]")


func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"


func get_bbcode_end_color_tag() -> String:
	return "[/color]"


func spawn_ally(tier: int, modifier: float) -> void:
	emit_signal("tutorial_2")
	$MinionSpawner.spawn_character(tier, modifier)


"""
	Erebos - The Greek god of darkness
	Ishtar - The Babylonian goddess of love and war
	Algiz - A Nordic rune representing protection and defense
	Nauthiz - A Nordic rune representing need and necessity
	Thurisaz - A Nordic rune representing destruction and chaos
	Ansuz - A Nordic rune representing wisdom and communication
	Kaos - A name inspired by the concept of chaos in mythology
	Eihwaz - A Nordic rune representing strength and stability
	Aegir - A Norse god of the sea
	Draugr - A Nordic undead creature
"""
