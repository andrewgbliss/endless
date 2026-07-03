class_name DanglingState extends MoveState

func process_physics(delta: float) -> void:
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
	parent.move(delta)
	if parent.velocity != Vector2.ZERO:
		if parent.input.is_pressing_down():
			state_machine.dispatch("crouch_idle")
		elif parent.input.is_running():
			state_machine.dispatch("run")
		else:
			state_machine.dispatch("walk")
	elif parent.input.is_pressing_down():
		state_machine.dispatch("crouch_idle")
		return
