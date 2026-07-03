class_name DeathState extends MoveState

func enter() -> void:
	parent.die(false)
	super.enter()

func process_frame(delta: float) -> void:
	parent.move(delta)
