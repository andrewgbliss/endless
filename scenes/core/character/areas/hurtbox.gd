class_name Hurtbox extends Area2D

var parent: CharacterController

func _ready() -> void:
	parent = get_parent() as CharacterController
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Node2D) -> void:
	if area is Hitbox:
		take_damage(area.damage)
		var direction_to_body = (area.global_position - global_position).normalized()
		parent.apply_knockback(-direction_to_body)
		
func take_damage(damage: int):
	parent.take_damage(damage)
	
