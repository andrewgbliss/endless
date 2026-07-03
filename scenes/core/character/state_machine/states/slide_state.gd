class_name SlideState extends MoveState

var slide_time: float = 0
var slide_stop_on_end: bool = false
var slide_time_elapsed: float = 0

func enter():
	parent.crouch()
	slide_time_elapsed = 0
	slide_time = parent.blackboard.slide_time
	parent.direction_lock = parent.slide()
	super.enter()

func process_physics(delta: float):
	parent.move(delta)
	slide_time_elapsed += delta
	if slide_time_elapsed >= slide_time:
		parent.stop()
		parent.stand()
		state_machine.dispatch("slide_stop")
