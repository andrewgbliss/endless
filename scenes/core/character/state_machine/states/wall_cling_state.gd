class_name WallClingState extends MoveState

var original_gravity_percent: float = 0
var current_gravity_percent: float = 0

func enter() -> void:
	super.enter()
	#parent.set_flip_to_input_direction()
	parent.blackboard.flip_h_lock = true
	parent.stop()
	original_gravity_percent = parent.blackboard.gravity_percent
	current_gravity_percent = parent.blackboard.wall_cling_gravity_percent
	parent.blackboard.gravity_percent = current_gravity_percent

func process_input(event: InputEvent) -> void:
	if parent.blackboard.paralyzed:
		return
	if event.is_action_pressed(parent.input.jump):
		state_machine.dispatch("wall_jump")
		return

func process_physics(delta: float) -> void:
	if current_gravity_percent > 0:
		parent.move(delta)
	if not parent.is_wall_clinging():
		state_machine.dispatch("falling")
		return

func exit() -> void:
	super.exit()
	#parent.reverse_flip()
	parent.blackboard.flip_h_lock = false
	parent.blackboard.gravity_percent = original_gravity_percent
