class_name SpawnState extends AnimationState

func enter() -> void:
	parent.spawn()
	super.enter()

func process_frame(_delta: float) -> void:
	if parent.animated_sprite and is_animation_finished:
		state_machine.dispatch("idle")
	elif not parent.animated_sprite:
		state_machine.dispatch("idle")
