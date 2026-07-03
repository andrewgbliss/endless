class_name SmashDownState extends AnimationState

var animation_started: String = "Smash Down Started"
var animation_performed: String = "Smash Down Performed"
var animation_collided: String = "Smash Down Collided"

var wait_finish_time: float = 0.5
var elapsed_time: float = 0

enum State {
	STARTED,
	PERFORMED,
	COLLIDED
}

var state = State.STARTED

func enter() -> void:
	super.enter()
	parent.blackboard.flip_h_lock = true
	parent.stop()
	state = State.STARTED
	elapsed_time = 0
	parent.direction_lock = Vector2.DOWN
	play_animation_name(animation_started)
	parent.smash_down_enable()

func exit() -> void:
	super.exit()
	parent.blackboard.flip_h_lock = false
	parent.direction_lock = Vector2.ZERO
	parent.smash_down_disable()

func process_physics(delta: float) -> void:
	if parent.move(delta):
		for i in parent.get_slide_collision_count():
			var col = parent.get_slide_collision(i)
			parent.play_collide_effect("smash_down_collision", col)
			
	if is_animation_finished:
		if state == State.STARTED:
			play_animation_name(animation_performed)
			state = State.PERFORMED
		elif state == State.PERFORMED:
			play_animation_name(animation_collided)
			state = State.COLLIDED
	if parent.is_on_floor() and is_animation_finished:
		if state != State.COLLIDED:
			play_animation_name(animation_collided)
			state = State.COLLIDED
		elif state == State.COLLIDED:
			elapsed_time += delta
			if elapsed_time > wait_finish_time:
				state_machine.dispatch("idle")
