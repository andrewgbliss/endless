class_name WalkState extends MoveState

func process_physics(delta: float) -> void:
	move_ground(delta)
	if parent.input.is_running():
		state_machine.dispatch("run")
		return
