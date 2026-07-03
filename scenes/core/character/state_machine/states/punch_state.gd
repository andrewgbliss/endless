class_name PunchState extends MoveState

var time_elapsed = 0
var total_time = 0.25

func enter() -> void:
	super.enter()
	parent.punch_enable()
	time_elapsed = 0
	
func process_physics(delta: float) -> void:
	parent.move(delta)
	time_elapsed += delta
	if time_elapsed > total_time:
		state_machine.dispatch("idle")
		return

func exit() -> void:
	super.exit()
	parent.punch_disable()
