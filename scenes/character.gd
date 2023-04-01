extends Area2D
class_name Character


signal died

var state: String = "move"
var target = null
var can_attack: bool = true
var health_points: float = 30
var initial_direction: Vector2

export var direction: Vector2 = Vector2.RIGHT
export var move_speed: float = 1
export var attack_range: float = 20
export var attack_damage: float = 10

onready var hit_box: HitBox = $HitBox
onready var hurt_box: HurtBox = $HurtBox
onready var attack_cooldown_timer: Timer = $AttackCooldown


func _ready() -> void:
	hurt_box.connect("take_damage", self, "take_damage")
	initial_direction = direction


func _physics_process(delta):
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
			state = "attack"
	else:
		state = "move"
		direction = initial_direction


func attack() -> void:
	if is_instance_valid(target):
		if can_attack:
			can_attack = false
			attack_cooldown_timer.start()
			hit_box.attack()
	else:
		state = "move"
		direction = initial_direction


func on_detection_area_entered(area: Area2D) -> void:
	if state != "chase" and state != "attack" and target == null: # Keep doing what I'm doing
		target = area
		state = "chase"
		target.connect("died", self, "on_target_death")


func take_damage(damage: float) -> void:
	health_points -= damage
	print("I took damage: ", damage)
	
	if health_points <= 0:
		emit_signal("died")
		print("I died")
		queue_free()


func on_attack_cooldown() -> void:
	can_attack = true


func on_target_death() -> void:
	target = null
