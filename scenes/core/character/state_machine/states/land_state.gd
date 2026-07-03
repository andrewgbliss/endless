class_name LandState extends MoveState

func process_physics(delta: float) -> void:
	if parent.velocity == Vector2.ZERO:
		if parent.is_on_floor() and is_animation_finished:
			state_machine.dispatch("idle")
			return
	else:
		move_ground_idle(delta)
