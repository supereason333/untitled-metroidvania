extends CharacterBody2D
class_name BaseEntity

signal death(entity:BaseEntity)
signal damaged(damage:int, from:Node)

@export var max_health:int
@export var movement_speed:float
@export var friendly:bool
@export var animation_player:AnimationPlayer
@export var sprite:AnimatedSprite2D
@export var hitbox:Area2D

@export_group("Components")
@export var contact_damage_component:Node
@export var interact_component:Node
@export var ai_component:EntityAIComponent

var health:int
var stunned := false
var dead := false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	if !ai_component:
		if not is_on_floor():
			velocity.y += gravity * delta
		velocity.x = move_toward(velocity.x, 0, 10)
		move_and_slide()

func _process(delta: float) -> void:
	pass

func take_damage(dmg:int, from:Node2D):
	if dead: return
	modulate = Color.RED
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.2)
	health -= dmg
	damaged.emit(dmg, from)
	if !friendly:
		knockback(clamp(position.x - from.position.x, -1, 1))
	if health <= 0:
		die()

func die():
	dead = true
	death.emit(self)
	if contact_damage_component:
		contact_damage_component.queue_free()
		contact_damage_component = null
	if interact_component:
		interact_component.queue_free()
		interact_component = null
	if ai_component:
		ai_component.queue_free()
		ai_component = null
	get_tree().create_timer(2).timeout.connect(queue_free)

func knockback(direction: float):
	stun()
	velocity = Vector2(direction * 70, 0)

func stun(time:float = 0.4):
	stunned = true
	get_tree().create_timer(time).timeout.connect(unstun)

func unstun():
	stunned = false
