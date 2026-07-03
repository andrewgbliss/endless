class_name StateMachinePlatformer extends Node

@export var animation_states: Dictionary[String, String] = {
	"SpawnState": "Spawn",
	"IdleState": "Idle",
	"WalkState": "Walk",
	"RunState": "Run",
	"JumpState": "Jump",
	"JumpFlipState": "Jump Flip",
	"FallingState": "Fall",
	"LandState": "Land",
	"DashState": "Dash",
	"CrouchIdleState": "Crouch Idle",
	"CrouchWalkState": "Crouch Walk",
	"DownThrustState": "Down Thrust",
	"UpThrustState": "Up Thrust",
	"RollState": "Roll",
	"SlideState": "Slide",
	"PushState": "Push",
	"PushIdleState": "Push Idle",
	"WallClingState": "Wall Cling",
	"WallJumpState": "Wall Jump",
	"DanglingState": "Dangling",
	"DamageState": "Damage",
	"DeathState": "Die",
	"PunchState": "Punch",
	"KickState": "Kick",
	"LadderIdleState": "Ladder Idle",
	"LadderClimbState": "Ladder Climb",
	"LedgeGrabState": "Ledge Grab",
	"LedgeClimbState": "Ledge Climb",
	"SwimState": "Swim",
	"SmashDownState": "Smash Down",
	"DropDownState": "Fall",
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
	states["JumpState"] = JumpState.new()
	states["JumpFlipState"] = JumpFlipState.new()
	states["FallingState"] = FallingState.new()
	states["LandState"] = LandState.new()
	states["DashState"] = DashState.new(true)
	states["CrouchIdleState"] = CrouchIdleState.new()
	states["CrouchWalkState"] = CrouchWalkState.new()
	states["DownThrustState"] = DownThrustState.new()
	states["UpThrustState"] = UpThrustState.new()
	states["RollState"] = RollState.new(true)
	states["SlideState"] = SlideState.new(true)
	states["PushState"] = PushState.new()
	states["PushIdleState"] = PushIdleState.new()
	states["WallClingState"] = WallClingState.new()
	states["WallJumpState"] = WallJumpState.new()
	states["DanglingState"] = DanglingState.new()
	states["DamageState"] = DamageState.new()
	states["DeathState"] = DeathState.new()
	states["PunchState"] = PunchState.new()
	states["KickState"] = KickState.new()
	states["LadderIdleState"] = LadderIdleState.new()
	states["LadderClimbState"] = LadderClimbState.new()
	states["LedgeGrabState"] = LedgeGrabState.new(true)
	states["LedgeClimbState"] = LedgeClimbState.new(true)
	states["SwimState"] = SwimState.new(true)
	states["SmashDownState"] = SmashDownState.new(true)
	states["DropDownState"] = DropDownState.new()
	
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

	state_machine.add_transition(null, states["CrouchIdleState"], "crouch_idle")
	state_machine.add_transition(null, states["CrouchWalkState"], "crouch_walk")

	state_machine.add_transition(null, states["DashState"], "dash")
	state_machine.add_transition(states["DashState"], states["IdleState"], "dash_stop")

	state_machine.add_transition(null, states["JumpState"], "jump")
	state_machine.add_transition(states["RunState"], states["JumpFlipState"], "jump_flip")
	state_machine.add_transition(null, states["FallingState"], "falling")
	state_machine.add_transition(null, states["LandState"], "land")

	state_machine.add_transition(null, states["RollState"], "roll")

	state_machine.add_transition(states["JumpState"], states["WallClingState"], "wall_cling")
	state_machine.add_transition(states["WallClingState"], states["WallJumpState"], "wall_jump")

	state_machine.add_transition(null, states["PunchState"], "punch")
	state_machine.add_transition(null, states["KickState"], "kick")

	state_machine.add_transition(states["JumpState"], states["UpThrustState"], "up_thrust")
	state_machine.add_transition(states["JumpState"], states["DownThrustState"], "down_thrust")

	state_machine.add_transition(null, states["SlideState"], "slide")
	state_machine.add_transition(states["SlideState"], states["IdleState"], "slide_stop")

	state_machine.add_transition(null, states["PushState"], "push")
	state_machine.add_transition(states["PushState"], states["PushIdleState"], "push_idle")

	state_machine.add_transition(states["IdleState"], states["DanglingState"], "dangling")

	state_machine.add_transition(states["LadderClimbState"], states["LadderIdleState"], "ladder_idle")
	state_machine.add_transition(null, states["LadderClimbState"], "ladder_climb")
#
	state_machine.add_transition(null, states["SwimState"], "swim")

	state_machine.add_transition(null, states["LedgeGrabState"], "ledge_grab")
	state_machine.add_transition(states["LedgeGrabState"], states["LedgeClimbState"], "ledge_climb")

	state_machine.add_transition(null, states["SmashDownState"], "smash_down")

	state_machine.add_transition(null, states["DamageState"], "damage")
	state_machine.add_transition(null, states["DeathState"], "death")
	
	state_machine.add_transition(null, states["DropDownState"], "drop_down")
	
func initial_dispatch():
	state_machine.enabled = true
	state_machine.dispatch("spawn")
