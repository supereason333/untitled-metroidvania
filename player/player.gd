extends BaseEntity
class_name Player

const JUMP_VELOCITY := -180.0
const JUMP_TIME_MAX := 5
var atk_damage := 20
var jump_time := 0
var is_jumping := false
var full_jump := false
var jump_amount := 2 # double jumps
var jump_left := jump_amount
var direction:int = 1
var direction_atk:int = 1

var since_last_attack := 0.0
var attack_cooldown := 0.5

var enimies_contact:Array[BaseEntity]

@onready var attack_area := $AttackRotate/AttackArea
@onready var attack_collision := $AttackRotate/AttackArea/CollisionShape2D
@onready var attack_rotate := $AttackRotate
@onready var immunity_timer := $ImmunityTimer

func _ready() -> void:
	super()
	Game.player_ref = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack_main") and since_last_attack >= attack_cooldown:
		since_last_attack -= attack_cooldown
		attack()
	if since_last_attack <= attack_cooldown:
		since_last_attack += delta
	attack_rotate.rotation = position.angle_to_point(get_global_mouse_position())

func _physics_process(delta:float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !stunned:
		# Handle Jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			is_jumping = true
			jump_left -= 1
		elif is_on_floor() :
			is_jumping = false
			jump_left = jump_amount
			jump_time = 0
			full_jump = false

		if is_jumping:
			if Input.is_action_pressed("jump") and jump_time < JUMP_TIME_MAX:
				velocity.y = JUMP_VELOCITY
				jump_time += 1
			elif Input.is_action_just_pressed("jump") and jump_left >= 1: # start of double jump
				jump_left -= 1 
				jump_time = 0
				full_jump = false
			elif jump_left >= 2 and not is_on_floor() and Input.is_action_just_pressed("jump"): # start of double jump after fall
				jump_left -= 2
				is_jumping = true
			elif Input.is_action_just_released("jump"):
				jump_time = JUMP_TIME_MAX
			
			if velocity.y >= -20 and Input.is_action_just_released("jump"):
				full_jump = true
				
			if not full_jump and Input.is_action_just_released("jump"):
				velocity.y += 70

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("left", "right")
	if direction:
		direction_atk = direction
	if direction and !stunned:
		velocity.x = move_toward(velocity.x, direction * movement_speed, 80)#direction * movement_speed
		if is_on_floor():
			animation_player.play("Run")
	else:
		if !stunned:
			velocity.x = move_toward(velocity.x, 0, 80)
		direction = 0
	
	if !direction:
		if velocity.y == 0:
			animation_player.play("Idle")
	if velocity.y > 0:
		animation_player.play("Fall")
	elif velocity.y < 0:
		animation_player.play("Jump")
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	
	move_and_slide()

func attack():
	#attack_collision.position.x = attack_collision.shape.get_rect().size.x / 2 * direction_atk
	attack_collision.modulate = Color.BLUE
	create_tween().tween_property(attack_collision, "modulate", Color.WHITE, 0.8)
	var targets = attack_area.get_overlapping_bodies()
	if targets:
		if !is_on_floor():
			velocity.y += -40 #+= Vector2(cos(attack_rotate.rotation), sin(attack_rotate.rotation)) * -20
	for target in targets:
		if target is BaseEntity:
			if !target.friendly:
				target.take_damage(atk_damage, self)

func _on_attack_area_body_entered(body: Node2D) -> void:
	pass

func _on_attack_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

func knockback(direction: float):
	stun()
	velocity = Vector2(direction * 70, -100)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is BaseEntity:
		if !body.friendly:
			enimies_contact.append(body)
			if body.contact_damage_component:
				take_damage(body.contact_damage_component.damage, body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if enimies_contact.find(body) != -1:
		enimies_contact.remove_at(enimies_contact.find(body))

func take_damage(dmg:int, from:Node2D):
	if immunity_timer.is_stopped(): 
		immunity_timer.start()
		super(dmg, from)
		knockback(snapped(clamp(position.x - from.position.x, -15, 15) / 15, 0.2))

func _on_immunity_timer_timeout() -> void:
	for enemy in enimies_contact:
		if is_instance_valid(enemy):
			if enemy.contact_damage_component:
				take_damage(enemy.contact_damage_component.damage, enemy)
				return

func _on_tree_exiting() -> void:
	Game.player_ref = null
