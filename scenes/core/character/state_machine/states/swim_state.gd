class_name SwimState extends MoveState

func enter() -> void:
	super.enter()
	parent.stop()
	parent.blackboard.allow_y_input = true
	
func exit() -> void:
	super.enter()
	parent.blackboard.allow_y_input = false

func process_input(event: InputEvent) -> void:
	if parent.blackboard.paralyzed:
		return
	if event.is_action_pressed(parent.input.jump):
		parent.jump()
		return

func process_physics(delta: float) -> void:
	parent.move(delta)
