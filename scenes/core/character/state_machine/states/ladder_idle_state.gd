class_name LadderIdleState extends MoveState

var original_gravity_percent = 0

func enter() -> void:
	super.enter()
	original_gravity_percent = parent.blackboard.gravity_percent
	parent.blackboard.gravity_percent = 0
	parent.blackboard.allow_y_input = true
	
func exit() -> void:
	super.enter()
	parent.blackboard.allow_y_input = false
	parent.blackboard.gravity_percent = original_gravity_percent

func process_physics(delta: float) -> void:
	parent.move(delta)
	var direction = parent.input.get_movement_direction()
	if direction != Vector2.ZERO:
		state_machine.dispatch("ladder_climb")
		return
	if not parent.is_on_ladder():
		state_machine.dispatch("idle")
		return
