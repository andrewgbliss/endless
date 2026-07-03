class_name CrouchIdleState extends MoveState

func enter() -> void:
	super.enter()
	parent.crouch()

func process_physics(delta: float) -> void:
	var is_top_colliding = parent.is_top_colliding()
	if parent.is_falling() and not is_top_colliding:
		parent.stand()
		state_machine.dispatch("falling")
		return
	parent.move(delta)
	if parent.velocity != Vector2.ZERO:
		if parent.input.is_pressing_crouch():
			state_machine.dispatch("crouch_walk")
			return
		if is_top_colliding:
			return
		parent.stand()
		if parent.input.is_running():
			state_machine.dispatch("run")
		else:
			state_machine.dispatch("walk")
	else:
		if not parent.input.is_pressing_crouch() and not is_top_colliding:
			parent.stand()
			state_machine.dispatch("idle")
			return
