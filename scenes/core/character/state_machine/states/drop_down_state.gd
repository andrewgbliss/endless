class_name DropDownState extends MoveState

func enter():
	super()
	parent.drop_down()
	
func process_physics(delta: float) -> void:
	move_air(delta)
