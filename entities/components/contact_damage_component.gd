extends Node

@export var damage:int
@export var knockback:bool = true
@export var reset:bool = false
@export var hitbox:Area2D

func _ready() -> void:
	if hitbox:
		hitbox.body_entered.connect(body_entered)
		hitbox.body_exited.connect(body_exited)

func body_entered(body:Node2D):
	pass

func body_exited(body:Node2D):
	pass
