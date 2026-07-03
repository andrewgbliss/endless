class_name DamageState extends AnimationState

func process_frame(delta: float) -> void:
	parent.move(delta)
	if is_animation_finished:
		state_machine.dispatch("idle")

func exit():
	super.exit()
	parent.stop()
