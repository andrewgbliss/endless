class_name CharacterBlackboard extends Resource

@export var device_index: int = 0
@export var allow_y_input: bool = false

@export_group("Animation")
@export var is_facing_right: bool = true
@export var facing_direction: Vector2 = Vector2.RIGHT

@export_group("Physics")
@export var speed: float = 300.0
@export var acceleration: float = 100.0
@export var acceleration_percent: float = 1.0
@export var friction: float = 50.0
@export var friction_percent: float = 1.0
@export var max_velocity: Vector2 = Vector2(1000.0, 1000.0)
@export var velocity: Vector2
@export var direction: Vector2
@export var aim_direction: Vector2
@export var gravity_dir: Vector2 = Vector2(0, 1)
@export var gravity_percent: float = 1.0
@export var movement_percent: float = 1.0
@export var run_multiplier: float = 2.0
@export var knockback_force: float = 500.0

@export_group("Jump")
@export var can_jump: bool = true
@export var jump_force: float = 500.0
@export var jump_count: int = 2

@export_group("Crouch")
@export var can_crouch: bool = true

@export_group("Dash")
@export var can_dash: bool = true
@export var dash_speed: float = 600.0
@export var dash_time: float = 0.1

@export_group("Push")
@export var can_push: bool = true
@export var push_force: float = 100.0

@export_group("Roll")
@export var can_roll: bool = true
@export var roll_speed: float = 100.0

@export_group("Slide")
@export var can_slide: bool = true
@export var slide_speed: float = 200.0
@export var slide_time: float = 1.0

@export_group("Wall Cling")
@export var can_wall_cling: bool = true
@export var can_wall_jump: bool = true
@export var wall_cling_point: Vector2 = Vector2.ZERO
@export var wall_cling_gravity_percent: float = 0.05

@export_group("Attack")
@export var can_punch: bool = true
@export var can_kick: bool = true
@export var can_up_thrust: bool = true
@export var up_thrust_force: float = 500.0
@export var can_down_thrust_jump: bool = true
@export var down_thrust_force: float = 500.0
@export var can_smash_down: bool = true
@export var smash_down_force: float = 500.0
@export var can_attack_left_trigger: bool = true
@export var can_attack_right_trigger: bool = true
@export var can_attack_left_bumper: bool = true
@export var can_attack_right_bumper: bool = true

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

var dash_time_elapsed: float = 0
var is_dashing = false
var is_jumping = false
var is_pushing = false
var current_jump_count = 0
var is_alive: bool = false
var paralyzed: bool = false
var flip_h_lock: bool = false
var flip_v_lock: bool = false
var original_gravity_percent: float = 0
var original_acceleration_percent: float = 0
var original_friction_percent: float = 0

func serialize():
	var data = {
		"is_alive": is_alive,
		"paralyzed": paralyzed,
		"flip_h_lock": flip_h_lock,
		"flip_v_lock": flip_v_lock,
		"speed": speed,
		"acceleration": acceleration,
		"friction": friction,
		"max_velocity_x": max_velocity.x,
		"max_velocity_y": max_velocity.y,
		"direction_x": direction.x,
		"direction_y": direction.y,
		"aim_direction_x": aim_direction.x,
		"aim_direction_y": aim_direction.y,
		"dash_speed": dash_speed,
		"run_multiplier": run_multiplier,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"is_facing_right": is_facing_right,
		"facing_direction_x": facing_direction.x,
		"facing_direction_y": facing_direction.y,
		"allow_y_input": allow_y_input,
		"device_index": device_index,
		"dash_time_elapsed": dash_time_elapsed,
		"is_dashing": is_dashing,
		"is_jumping": is_jumping,
		"is_pushing": is_pushing,
		"can_jump": can_jump,
		"can_dash": can_dash,
		"can_push": can_push,
		"jump_force": jump_force,
		"jump_count": jump_count,
		"current_jump_count": current_jump_count,
	}
	return data

func deserialize(data):
	if data.has("is_alive"):
		is_alive = data["is_alive"]
	if data.has("paralyzed"):
		paralyzed = data["paralyzed"]
	if data.has("flip_h_lock"):
		flip_h_lock = data["flip_h_lock"]
	if data.has("flip_v_lock"):
		flip_v_lock = data["flip_v_lock"]
	if data.has("speed"):
		speed = data["speed"]
	if data.has("acceleration"):
		acceleration = data["acceleration"]
	if data.has("friction"):
		friction = data["friction"]
	if data.has("max_velocity_x") and data.has("max_velocity_y"):
		max_velocity = Vector2(data["max_velocity_x"], data["max_velocity_y"])
	if data.has("direction_x") and data.has("direction_y"):
		direction = Vector2(data["direction_x"], data["direction_y"])
	if data.has("aim_direction_x") and data.has("aim_direction_y"):
		aim_direction = Vector2(data["aim_direction_x"], data["aim_direction_y"])
	if data.has("dash_speed"):
		dash_speed = data["dash_speed"]
	if data.has("run_multiplier"):
		run_multiplier = data["run_multiplier"]
	if data.has("velocity_x") and data.has("velocity_y"):
		velocity = Vector2(data["velocity_x"], data["velocity_y"])
	if data.has("is_facing_right"):
		is_facing_right = data["is_facing_right"]
	if data.has("facing_direction_x") and data.has("facing_direction_y"):
		facing_direction = Vector2(data["facing_direction_x"], data["facing_direction_y"])
	if data.has("allow_y_input"):
		allow_y_input = data["allow_y_input"]
	if data.has("device_index"):
		device_index = data["device_index"]
	if data.has("dash_time_elapsed"):
		dash_time_elapsed = data["dash_time_elapsed"]
	if data.has("is_dashing"):
		is_dashing = data["is_dashing"]
	if data.has("is_jumping"):
		is_jumping = data["is_jumping"]
	if data.has("is_pushing"):
		is_pushing = data["is_pushing"]
	if data.has("can_jump"):
		can_jump = data["can_jump"]
	if data.has("can_dash"):
		can_dash = data["can_dash"]
	if data.has("can_push"):
		can_push = data["can_push"]
	if data.has("jump_force"):
		jump_force = data["jump_force"]
	if data.has("jump_count"):
		jump_count = data["jump_count"]
	if data.has("current_jump_count"):
		current_jump_count = data["current_jump_count"]
