extends EntityAIComponent

signal chase_started
signal chase_ended

@export var chase_time := 3.0
@export var chase_cooldown := 5.0

@onready var view_area := $View
@onready var chase_timer := $ChaseTimer
@onready var chase_cooldown_timer := $ChaseCooldownTimer

var direction := 0
var player:BaseEntity

func _ready() -> void:
	view_area.get_child(0).shape.radius = view_dist
	chase_timer.wait_time = chase_time
	chase_cooldown_timer.wait_time = chase_cooldown

func _physics_process(delta: float) -> void:
	if not entity.is_on_floor():
		entity.velocity.y += entity.gravity * delta
	if !entity.stunned:
		if !chase_timer.is_stopped():
			entity.velocity.x = entity.movement_speed * direction
		else:
			entity.velocity.x = move_toward(entity.velocity.x, 0, 10)
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0, 10)
	
	entity.move_and_slide()

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		if chase_cooldown_timer.is_stopped():
			chase_cooldown_timer.start()

func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func _on_chase_timer_timeout() -> void:
	chase_ended.emit()
	direction = 0
	if player:
		chase_cooldown_timer.start()


func _on_chase_cooldown_timer_timeout() -> void:
	if player:
		direction = clamp(player.position.x - entity.position.x, -1, 1)
		chase_started.emit()
		chase_timer.start()
