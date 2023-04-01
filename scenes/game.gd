extends Node2D


var active_rune: String = ""
var current_letter_index: int = -1
onready var current_rune_label: RichTextLabel = $"%CurrentRuneRichTextLabel"

export var blue: Color = Color.blue
export var green: Color = Color.green
export var red: Color = Color.red

var rune_names: Array = [
	"Erebos",
	"Ishtar",
	"Algiz",
	"Nauthiz",
	"Thurisaz",
	"Ansuz",
	"Kaos",
	"Eihwaz",
	"Aegir",
	"Draugr"
]


func _unhandled_input(event: InputEvent) -> void:
	OS.set_ime_active(false)
	if event is InputEventKey and event.is_pressed():
		var typed_event: InputEventKey = event
		
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		print(key_typed)
		
		if active_rune == "":
			find_new_active_rune(key_typed)
		else:
			var next_character: String = active_rune.substr(current_letter_index, 1)
			
			if key_typed == next_character:
				print("success")
				current_letter_index += 1
				set_next_character(current_letter_index)
				
				if current_letter_index == active_rune.length():
					print("word completed")
					current_letter_index = -1
					active_rune = ""
					
					spawn_ally()
			else: # incorrectly typed.
				print("not success")


func find_new_active_rune(typed_character: String) -> void:
	var prompt: String = "lorem"
	
	var next_character: String = prompt.substr(0, 1)
	print(typed_character)
	print(next_character)
	if typed_character == next_character:
		print("HOLA")
		current_letter_index = 1
		set_next_character(current_letter_index)
		active_rune = prompt


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


func spawn_ally() -> void:
	$MinionSpawner.spawn_character()


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
