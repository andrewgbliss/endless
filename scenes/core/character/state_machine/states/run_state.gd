class_name RunState extends MoveState

func process_physics(delta: float) -> void:
	move_ground(delta)
	if not parent.input.is_running():
		state_machine.dispatch("walk")
		return
