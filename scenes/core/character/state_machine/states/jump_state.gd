class_name JumpState extends MoveState

func enter() -> void:
	super.enter()
	parent.jump()

func process_physics(delta: float) -> void:
	move_air(delta)
	if not parent.input.is_pressing_jump():
		parent.stop()
		state_machine.dispatch("falling")
		return
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
	if parent.input.is_pressing_up():
		state_machine.dispatch("up_thrust")
		return
	if parent.input.is_pressing_down():
		state_machine.dispatch("down_thrust")
		return
	
