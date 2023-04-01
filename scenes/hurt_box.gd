extends Area2D
class_name HurtBox

signal take_damage

func take_damage(damage: float) -> void:
	emit_signal("take_damage", damage)
