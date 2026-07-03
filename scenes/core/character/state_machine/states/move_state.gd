class_name MoveState extends AnimationState

func process_input(event: InputEvent) -> void:
	if parent.blackboard.paralyzed:
		return
	if event.is_action_pressed(parent.input.jump) and parent.is_on_floor() and parent.input.is_pressing_down():
		state_machine.dispatch("drop_down")
		return
	if event.is_action_pressed(parent.input.dash) and parent.can_dash():
		state_machine.dispatch("dash")
		return
	if event.is_action_pressed(parent.input.roll) and parent.can_roll():
		state_machine.dispatch("roll")
		return
	if event.is_action_pressed(parent.input.slide) and parent.can_slide():
		state_machine.dispatch("slide")
		return
	if event.is_action_pressed(parent.input.jump) and parent.can_jump():
		if parent.input.is_running():
			state_machine.dispatch("jump_flip")
		else:
			state_machine.dispatch("jump")
		return
	if event.is_action_pressed(parent.input.crouch) and parent.can_crouch():
		state_machine.dispatch("crouch_idle")
		return
	if event.is_action_pressed(parent.input.smash_down) and parent.can_smash_down():
		state_machine.dispatch("smash_down")
		return
	if event.is_action_pressed(parent.input.punch) and parent.can_punch():
		state_machine.dispatch("punch")
		return
	if event.is_action_pressed(parent.input.kick) and parent.can_kick():
		state_machine.dispatch("kick")
		return

func process_physics(_delta: float) -> void:
	parent.calc_velocity_from_blackboard()

func move_ground_idle(delta: float):
	if parent.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if parent.is_falling():
			state_machine.dispatch("falling")
			return
	parent.move(delta)
	update_move_animation()
	if parent.is_pushing():
		state_machine.dispatch("push")
		return
	if parent.velocity != Vector2.ZERO:
		if parent.input.is_running():
			state_machine.dispatch("run")
		else:
			state_machine.dispatch("walk")
		return
	if parent.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if parent.is_dangling():
			state_machine.dispatch("dangling")
			return
		if parent.is_on_ladder() and parent.input.is_pressing_up():
			state_machine.dispatch("ladder_climb")
			return
	
func move_ground(delta: float):
	if parent.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if parent.is_falling():
			state_machine.dispatch("falling")
			return
	parent.move(delta)
	update_move_animation()
	if parent.is_pushing():
		state_machine.dispatch("push")
		return
	if parent.velocity == Vector2.ZERO:
		state_machine.dispatch("idle")
		return
	if parent.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if parent.is_on_ladder() and parent.input.is_pressing_up():
			state_machine.dispatch("ladder_climb")
			return
	
func move_air(delta: float):
	parent.move(delta)
	if parent.is_on_floor():
		state_machine.dispatch("land")
		return
	if parent.is_on_ladder() and parent.input.is_pressing_up():
		state_machine.dispatch("ladder_climb")
		return
	if parent.is_wall_clinging():
		state_machine.dispatch("wall_cling")
		return
	if parent.is_ledge_grabbing():
		state_machine.dispatch("ledge_grab")
		return
