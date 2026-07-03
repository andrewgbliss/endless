class_name FallingState extends MoveState

func process_physics(delta: float) -> void:
	move_air(delta)
	if parent.input.is_pressing_down():
		state_machine.dispatch("down_thrust")
		return
