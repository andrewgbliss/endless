class_name StateMachineTopDown extends Node

@export var animation_states: Dictionary[String, String] = {
	"SpawnState": "Spawn",
	"IdleState": "Idle",
	"WalkState": "Walk",
	"RunState": "Run",
	"PushState": "Push",
	"PushIdleState": "Push Idle",
}

@export var direction_modifiers: Dictionary[String, String] = {
	"Right": "Right",
	"Down": "Down",
	"Up": "Up",
}

var states = {}
var state_machine: StateMachine
var parent: CharacterController

func _ready() -> void:
	parent = get_parent()
	state_machine = StateMachine.new()
	state_machine.parent = parent
	parent.state_machine = state_machine
	call_deferred("_after_ready")
	
func _after_ready():
	add_states()
	add_transitions()
	initial_dispatch()
	
func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func add_states():
	states["SpawnState"] = SpawnState.new()
	states["IdleState"] = IdleState.new()
	states["WalkState"] = WalkState.new()
	states["RunState"] = RunState.new()
	states["PushState"] = PushState.new()
	states["PushIdleState"] = PushIdleState.new()
	
	for s in states:
		var state = states[s]
		state.name = s
		state.parent = parent
		state.state_machine = state_machine
		if state is AnimationState and animation_states.has(s):
			state.animation_name = animation_states[s]

func add_transitions():
	state_machine.add_transition(null, states["SpawnState"], "spawn")
	state_machine.add_transition(null, states["IdleState"], "idle")
	state_machine.add_transition(null, states["WalkState"], "walk")
	state_machine.add_transition(null, states["RunState"], "run")
	state_machine.add_transition(null, states["PushState"], "push")
	state_machine.add_transition(states["PushState"], states["PushIdleState"], "push_idle")

func initial_dispatch():
	state_machine.enabled = true
	state_machine.dispatch("spawn")
