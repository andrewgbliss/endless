class_name PushIdleState extends MoveState

func process_physics(delta: float) -> void:
	parent.move(delta)
	if parent.input.is_pressing_crouch():
		state_machine.dispatch("crouch_idle")
		return
	if parent.velocity != Vector2.ZERO:
		if parent.is_pushing():
			state_machine.dispatch("push")
		elif parent.input.is_walking():
			state_machine.dispatch("walk")
		elif parent.input.is_running():
			state_machine.dispatch("run")
