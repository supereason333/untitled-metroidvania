extends Area2D
class_name SceneDoor

@export var collision_shape:CollisionShape2D
@export var spawnpoint := Node2D
@export var door_id:int
@export var other_scene:PackedScene

var used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if used: return
	if body is Player:
		used = true
		print("ADAWDADW")
		Game.change_scene(other_scene.resource_path, door_id)
