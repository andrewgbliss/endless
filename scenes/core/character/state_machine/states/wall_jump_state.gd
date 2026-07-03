class_name WallJumpState extends MoveState

var aim_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	parent.wall_jump()

func process_physics(delta: float) -> void:
	parent.move(delta)
	if parent.is_on_floor():
		state_machine.dispatch("land")
		return
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
