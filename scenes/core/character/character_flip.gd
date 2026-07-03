class_name CharacterFlip extends Node2D

var facing_right_modifier: int = 1
var is_facing_right: bool = true
var previous_facing_right: bool = true
var parent

func _ready():
	parent = get_parent()
	call_deferred("_after_ready")
	
func _after_ready():
	is_facing_right = parent.blackboard.is_facing_right
	
func _physics_process(delta: float) -> void:
	if not parent.blackboard.is_alive:
		return
	_update_facing_direction()

func _update_facing_direction():
	var new_is_facing_right = parent.blackboard.is_facing_right
	if not parent.blackboard.flip_h_lock:
		match parent.input.aim_type:
			PlayerInput.INPUT_TYPE.MOUSE:
				var mouse_pos = parent.get_global_mouse_position()
				new_is_facing_right = mouse_pos.x > parent.position.x
			PlayerInput.INPUT_TYPE.TOUCH:
				new_is_facing_right = parent.input.touch_position.x > parent.global_position.x
			PlayerInput.INPUT_TYPE.JOYSTICK:
				new_is_facing_right = parent.input.get_aim_direction().x > 0
			PlayerInput.INPUT_TYPE.DEFAULT:
				if parent.velocity.x != 0:
					new_is_facing_right = parent.velocity.x > 0
	if new_is_facing_right != is_facing_right:
		is_facing_right = new_is_facing_right
		parent.blackboard.is_facing_right = is_facing_right
		flip()

func flip():
	if parent.blackboard.is_facing_right:
		parent.scale.x = parent.scale.y * facing_right_modifier
	else:
		parent.scale.x = parent.scale.y * -facing_right_modifier
