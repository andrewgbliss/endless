class_name CrouchWalkState extends MoveState

func process_physics(delta: float) -> void:
	var is_top_colliding = parent.is_top_colliding()
	if parent.is_falling() and not is_top_colliding:
		parent.stand()
		state_machine.dispatch("falling")
		return
	parent.move(delta)
	if parent.velocity == Vector2.ZERO:
		state_machine.dispatch("crouch_idle")
	elif not parent.input.is_pressing_crouch() and not is_top_colliding:
		parent.stand()
		state_machine.dispatch("idle")
