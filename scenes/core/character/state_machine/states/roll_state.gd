class_name RollState extends MoveState

func enter() -> void:
	super.enter()
	parent.crouch()
	parent.direction_lock = parent.roll()

func process_input(event: InputEvent) -> void:
	if parent.blackboard.paralyzed:
		return
	#elif event.is_action_pressed("attack_left_hand") or event.is_action_pressed("attack_right_hand"):
		#super.attack()

func process_physics(delta: float):
	parent.move(delta)
	if is_animation_finished:
		parent.stop()
		parent.stand()
		state_machine.dispatch("idle")
	
