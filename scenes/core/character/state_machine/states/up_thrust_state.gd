class_name UpThrustState extends MoveState

func enter() -> void:
	super.enter()
	parent.up_thrust_enable()
	
func process_physics(delta: float) -> void:
	parent.move(delta)
	#if parent.is_on_ladder() and parent.controls.is_pressing_up():
		#state_machine.dispatch("ladder_climb")
		#return
	if parent.is_on_floor() or not parent.input.is_pressing_up():
		state_machine.dispatch("idle")
		return

func exit() -> void:
	super.exit()
	parent.up_thrust_disable()
