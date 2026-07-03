class_name StateMachine extends RefCounted

var enabled: bool = false
var transitions: Dictionary = {}
var current_state: State
var parent: CharacterController

signal active_state_changed
		
func change_state(new_state: State) -> void:
	if not enabled:
		return
	if current_state == new_state:
		return
	if current_state:
		current_state.exit()
	active_state_changed.emit(new_state, current_state)
	current_state = new_state
	current_state.enter()
	
func process_input(event: InputEvent) -> void:
	if not enabled:
		return
	if not current_state:
		return
	current_state.process_input(event)

func process_frame(delta: float) -> void:
	if not enabled:
		return
	if not current_state:
		return
	current_state.process_frame(delta)

func process_physics(delta: float) -> void:
	if not enabled:
		return
	if not current_state:
		return
	current_state.process_physics(delta)
		
func dispatch(transition_name: String):
	if not enabled:
		return
	if not transitions.has(transition_name):
		return
	var s = transitions[transition_name]
	var state_a = s[0]
	var state_b = s[1]
	if state_b and state_b.enabled:
		if state_a == null and current_state != null:
			state_a = current_state
		if state_a and state_a.enabled:
			state_a.exit()
		
		active_state_changed.emit(state_b, state_a)
		current_state = state_b
		current_state.enter()

func add_transition(state_a: State, state_b: State, transition_name: String):
	if transitions.has(transition_name):
		return
	transitions[transition_name] = [state_a, state_b]
