extends BaseEntity


func _on_basic_entity_ai_chase_started() -> void:
	animation_player.play("prejump")


func _on_basic_entity_ai_chase_ended() -> void:
	animation_player.play("idle")


func _on_death(entity: BaseEntity) -> void:
	animation_player.play("death")
