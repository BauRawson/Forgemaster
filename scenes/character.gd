extends Area2D
class_name Character


signal died

var state: String
var target = null
var can_attack: bool = true
var initial_direction: Vector2

export var direction: Vector2 = Vector2.RIGHT
export var move_speed: float = 1
export var attack_range: float = 20
export var attack_damage: float = 10
export var health_points: float = 30

onready var hit_box: HitBox = $HitBox
onready var hurt_box: HurtBox = $HurtBox
onready var attack_cooldown_timer: Timer = $AttackCooldown

var nearby_characters: Dictionary = {}
var damage_popup_scene = load("res://scenes/damage_popup.tscn")


func _ready() -> void:
	hurt_box.connect("take_damage", self, "take_damage")
	initial_direction = direction
	change_state("move")
	
	$Sprite/CPUParticles2D.emitting = true


func _physics_process(delta):
	$Sprite.flip_h = direction.x < 0
	
	if state == "move":
		move()
	elif state == "chase":
		chase()
	elif state == "attack":
		attack()


func move() -> void:
	position += direction * move_speed


func chase() -> void:
	if is_instance_valid(target):
		if global_position.distance_to(target.global_position) > attack_range:
			direction = (target.global_position - global_position).normalized()
			position += direction * move_speed
		else:
			change_state("attack")
	else:
		change_state("move")
		direction = initial_direction


func attack() -> void:
	if is_instance_valid(target):
		if global_position.distance_to(target.global_position) <= attack_range:
			if can_attack:
				can_attack = false
				attack_cooldown_timer.start()
				hit_box.attack()
				$AnimationPlayer.play("attack")
		else:
			target = null # Target is far away, remove. This sucks :P
			change_state("move")
	else:
		change_state("move")
		direction = initial_direction
		$AnimationPlayer.play("walk")


func on_detection_area_entered(area: Area2D) -> void:
	add_to_nearby_characters(area)


func take_damage(damage: float) -> void:
	health_points -= damage
	var damage_popup = damage_popup_scene.instance()
	get_parent().add_child(damage_popup)
	damage_popup.global_position = global_position
	damage_popup.popup(damage)
	
	if health_points <= 0:
		emit_signal("died")
		queue_free()


func on_attack_cooldown() -> void:
	can_attack = true


func on_target_death() -> void:
	target = null


func change_state(state: String) -> void:
	self.state = state
	$Label.text = state
	
	if state == "move":
		direction = initial_direction


func add_to_nearby_characters(area) -> void:
	nearby_characters[area.name] = area
	area.connect("died", self, "remove_from_nearby_characters", [area])
	
	if not is_instance_valid(target):
		target = area
		change_state("chase")


func remove_from_nearby_characters(area) -> void:
	if nearby_characters.has(area.name):
		nearby_characters.erase(area.name)
	
	if target == area:
		target = null
		change_state("move")
		find_new_target()


func find_new_target() -> void:
	if not nearby_characters.empty():
		target = nearby_characters.values()[0]
		change_state("chase")
		print("New target ", target.name)


func on_detection_area_exited(area: Area2D) -> void:
	remove_from_nearby_characters(area)
