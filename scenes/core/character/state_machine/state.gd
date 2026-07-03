class_name State extends RefCounted

@export var enabled: bool = true

var name: String
var parent: CharacterController
var state_machine: StateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> void:
	pass

func process_frame(_delta: float) -> void:
	pass
	
func process_physics(_delta: float) -> void:
	pass
