extends Area2D
class_name HitBox


onready var animation_player: AnimationPlayer = $AnimationPlayer


func attack() -> void:
	animation_player.play("attack")


func on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		area.take_damage(get_parent().attack_damage)
