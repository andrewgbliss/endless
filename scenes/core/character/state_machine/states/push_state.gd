class_name PushState extends MoveState

func process_physics(delta: float) -> void:
	if parent.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if parent.is_falling():
			state_machine.dispatch("falling")
			return
	parent.move(delta)
	if not parent.is_trying_to_push():
		state_machine.dispatch("push_idle")
