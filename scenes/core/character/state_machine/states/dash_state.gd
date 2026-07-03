class_name DashState extends AnimationState

var dash_time_elapsed: float = 0
var dash_time: float = 0

func enter():
	dash_time_elapsed = 0
	dash_time = parent.blackboard.dash_time
	parent.dash()
	super ()

func process_physics(delta: float):
	dash_time_elapsed += delta
	if dash_time_elapsed >= dash_time:
		parent.stop()
		state_machine.dispatch("dash_stop")
	else:
		parent.move(delta)
