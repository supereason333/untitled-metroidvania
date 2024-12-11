extends Node

var player_ref:BaseEntity
var last_door_id := -1

func change_scene(scene:String, door_id:int):
	player_ref.position = Vector2.ZERO
	player_ref.reparent(self)
	last_door_id = door_id
	get_tree().call_deferred("change_scene_to_file", scene)
