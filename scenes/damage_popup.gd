extends Node2D

export var speed: int = 200
export var friction: int = 15
var shift_direction: Vector2 = Vector2.ZERO

onready var label: Label = $Label


func popup(damage: int) -> void:
	label.text = str(damage)
	$AnimationPlayer.play("damage_popup")
	shift_direction += Vector2(rand_range(-1, 1), rand_range(-1, 1))


func _process(delta: float) -> void:
	global_position += speed * shift_direction * delta
	speed = max(speed - friction * delta, 0)
