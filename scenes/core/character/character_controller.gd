class_name CharacterController extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var character_sheet: CharacterSheet
@export var blackboard: CharacterBlackboard
@export var input: CharacterInput

@export_group("Spawning")
@export var spawn_position: Node2D

@export_group("Collision")
@export var standing_collision_shape: CollisionShape2D
@export var crouch_collision_shape: CollisionShape2D
@export var swimming_collision_shape: CollisionShape2D

@export_group("Hitboxes")
@export var down_thrust_hitbox: Hitbox
@export var up_thrust_hitbox: Hitbox
@export var smash_down_hitbox: Hitbox
@export var punch_hitbox: Hitbox
@export var kick_hitbox: Hitbox

@export_group("Raycasts")
@export var top_raycast_left: RayCast2D
@export var top_raycast_right: RayCast2D
@export var dangling_raycast: RayCast2D
@export var ladder_raycast: RayCast2D
@export var ledge_grab_raycast: RayCast2D

var state_machine: StateMachine
var direction_lock = Vector2.ZERO

signal spawned(pos: Vector2)
signal died(character: CharacterController)

enum EnvironmentType {
	DEFAULT,
	WATER,
	ICE,
}

var environment_type = {
	EnvironmentType.DEFAULT: {
		'gravity_percent': 1.0,
		'acceleration_percent': 1.0,
		'friction_percent': 1.0,
	},
	EnvironmentType.WATER: {
		'gravity_percent': 0.1,
		'acceleration_percent': 1.0,
		'friction_percent': 1.0,
	},
	EnvironmentType.ICE: {
		'gravity_percent': 1.0,
		'acceleration_percent': 1.0,
		'friction_percent': 0.05,
	},
}

var environment_type_values = {
	'default': EnvironmentType.DEFAULT,
	'water': EnvironmentType.WATER,
	'ice': EnvironmentType.ICE,
}

var current_environment_type = EnvironmentType.DEFAULT
var water_tilemaps: Array[TileMapLayer] = []

func _ready() -> void:
	init()
	
func init():
	hide()
	blackboard.original_gravity_percent = blackboard.gravity_percent
	blackboard.original_acceleration_percent = blackboard.acceleration_percent
	blackboard.original_friction_percent = blackboard.friction_percent
	blackboard.paralyzed = true
	if not blackboard.is_facing_right:
		flip_h()
	detect_water_tilemaps()

func detect_water_tilemaps():
	var water_tilemaps_nodes = get_tree().get_nodes_in_group("water_tilemap")
	water_tilemaps = []
	for tile_map in water_tilemaps_nodes:
		if tile_map is TileMapLayer:
			water_tilemaps.append(tile_map)

func spawn():
	blackboard.is_alive = true
	velocity = Vector2.ZERO
	blackboard.paralyzed = false
	position = spawn_position.position
	show()
	stand()
	spawned.emit(global_position)
	
func paralyze():
	blackboard.paralyzed = true
	velocity = Vector2.ZERO

func die(hide_after: bool = true):
	blackboard.is_alive = false
	died.emit(self)
	blackboard.paralyzed = true
	if blackboard.garbage:
		await get_tree().create_timer(blackboard.garbage_time).timeout
		call_deferred("queue_free")
	else:
		await get_tree().create_timer(blackboard.garbage_time).timeout
		if hide_after:
			hide()
	
func flip_h():
	animated_sprite.flip_h = not blackboard.is_facing_right
	
func apply_gravity(delta: float):
	velocity += get_gravity() * blackboard.gravity_dir.normalized() * blackboard.gravity_percent * delta
	
func move(delta):
	if motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if not is_on_floor():
			apply_gravity(delta)
		else:
			blackboard.is_jumping = false
			reset_jump_count()
		
	calc_velocity_from_blackboard()
	
	if move_and_slide():
		handle_collisions()
		return true
	else:
		if blackboard.is_pushing:
			blackboard.is_pushing = false

	if motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if is_in_water(global_position):
			state_machine.dispatch("swim")
			change_environment_type(EnvironmentType.WATER)
			swim()
		elif not is_on_wall():
			if current_environment_type == EnvironmentType.WATER:
				stand()
				state_machine.dispatch("jump")
			change_environment_type(EnvironmentType.DEFAULT)
			
	return false
	
func calc_velocity_from_blackboard():
	var speed_multiplier: float = 1.0
	if input.is_running():
		speed_multiplier = blackboard.run_multiplier
	var input_direction = input.get_movement_direction()
	if direction_lock != Vector2.ZERO:
		input_direction = direction_lock
	blackboard.direction = input_direction
	if blackboard.allow_y_input:
		velocity = calc_velocity(
			velocity,
			blackboard.direction,
			blackboard.speed * blackboard.movement_percent * speed_multiplier,
			blackboard.acceleration * blackboard.acceleration_percent,
			blackboard.friction * blackboard.friction_percent,
			blackboard.max_velocity
		)
	else:
		velocity = calc_x_velocity(
			velocity,
			blackboard.direction,
			blackboard.speed * blackboard.movement_percent * speed_multiplier,
			blackboard.acceleration * blackboard.acceleration_percent,
			blackboard.friction * blackboard.friction_percent,
			blackboard.max_velocity
		)
	blackboard.velocity = velocity
	
func calc_x_velocity(v: Vector2, d: Vector2, s: float, a: float, f: float, c: Vector2):
	if d != Vector2.ZERO:
		v.x = move_toward(v.x, d.x * s, a)
	else:
		v.x = move_toward(v.x, 0, f)
	v = v.clamp(-c, c)
	return v
		
func calc_velocity(v: Vector2, d: Vector2, s: float, a: float, f: float, c: Vector2):
	if d != Vector2.ZERO:
		v = v.move_toward(d * s, a)
	else:
		v = v.move_toward(Vector2.ZERO, f)
	v = v.clamp(-c, c)
	return v
	
func handle_collisions():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider is RigidBody2D:
			if blackboard.can_push and is_pushing():
				blackboard.is_pushing = true
				collider.apply_central_impulse(col.get_normal() * -blackboard.push_force)
		if collider is TileMapLayer and current_environment_type != EnvironmentType.WATER:
			calc_environment_type_from_tilemap_layer(col, collider)
		
func get_type_from_tilemap_layer(col: KinematicCollision2D, tilemap: TileMapLayer):
	var contact_point = col.get_position() - col.get_normal() * 1.0
	var local_pos = tilemap.to_local(contact_point)
	var cell_coords = tilemap.local_to_map(local_pos)
	var cell = tilemap.get_cell_tile_data(cell_coords)
	if cell:
		var tile_type = cell.get_custom_data("type")
		return tile_type
	return null

func calc_environment_type_from_tilemap_layer(col: KinematicCollision2D, tilemap: TileMapLayer):
	var tile_type = get_type_from_tilemap_layer(col, tilemap)
	if tile_type and environment_type_values.has(tile_type):
		change_environment_type(environment_type_values[tile_type])
		return
	
func is_in_water(world_pos: Vector2) -> bool:
	for tile_map in water_tilemaps:
		var coords = tile_map.local_to_map(world_pos)
		var cell = tile_map.get_cell_tile_data(coords)
		if cell and cell.get_custom_data("type") == "water":
			return true
	return false

func change_environment_type(new_environment_type: EnvironmentType):
	current_environment_type = new_environment_type
	if current_environment_type == EnvironmentType.DEFAULT:
		blackboard.gravity_percent = blackboard.original_gravity_percent
		blackboard.acceleration_percent = blackboard.original_acceleration_percent
		blackboard.friction_percent = blackboard.original_friction_percent
	elif current_environment_type == EnvironmentType.WATER:
		blackboard.gravity_percent = environment_type[current_environment_type]['gravity_percent']
		blackboard.acceleration_percent = environment_type[current_environment_type]['acceleration_percent']
		blackboard.friction_percent = environment_type[current_environment_type]['friction_percent']
	elif current_environment_type == EnvironmentType.ICE:
		blackboard.gravity_percent = environment_type[current_environment_type]['gravity_percent']
		blackboard.acceleration_percent = environment_type[current_environment_type]['acceleration_percent']
		blackboard.friction_percent = environment_type[current_environment_type]['friction_percent']

func stop():
	velocity = Vector2.ZERO
	direction_lock = Vector2.ZERO

func delta_stop(delta: float):
	velocity = velocity.move_toward(Vector2.ZERO, delta * 100)

func jump():
	stand()
	blackboard.current_jump_count += 1
	velocity.y = - blackboard.jump_force * blackboard.gravity_dir.y

func can_jump():
	if is_top_colliding():
		return false
	return blackboard.current_jump_count < blackboard.jump_count - 1

func reset_jump_count():
	blackboard.current_jump_count = 0
	
func is_falling():
	return velocity.y >= 0.0 and not is_on_floor()
	
func dash():
	stand()
	var direction = Vector2.ZERO
	if input.double_tap_direction != input.DOUBLE_TAP_DIRECTION.NONE:
		direction = input.get_double_tap_direction()
		input.double_tap_direction = input.DOUBLE_TAP_DIRECTION.NONE
	else:
		direction = input.get_aim_direction()
	stop()
	velocity += direction * blackboard.dash_speed
	direction_lock = direction
	return direction

func can_dash():
	if not blackboard.can_dash or is_top_colliding():
		return false
	return true

func is_top_colliding():
	var is_top_colliding = false
	if top_raycast_left and top_raycast_right:
		var is_top_colliding_left = top_raycast_left.is_colliding()
		var is_top_colliding_right = top_raycast_right.is_colliding()
		is_top_colliding = is_top_colliding_left or is_top_colliding_right
	return is_top_colliding

func crouch():
	if standing_collision_shape:
		standing_collision_shape.disabled = true
	if swimming_collision_shape:
		swimming_collision_shape.disabled = true
	if crouch_collision_shape:
		crouch_collision_shape.disabled = false

func stand():
	if standing_collision_shape:
		standing_collision_shape.disabled = false
	if swimming_collision_shape:
		swimming_collision_shape.disabled = true
	if crouch_collision_shape:
		crouch_collision_shape.disabled = true
		
func swim():
	if standing_collision_shape:
		standing_collision_shape.disabled = true
	if swimming_collision_shape:
		swimming_collision_shape.disabled = false
	if crouch_collision_shape:
		crouch_collision_shape.disabled = true
		
func up_thrust_enable():
	velocity.y = - blackboard.up_thrust_force * blackboard.gravity_dir.y
	if up_thrust_hitbox:
		up_thrust_hitbox.get_node("CollisionShape2D").disabled = false
		
func up_thrust_disable():
	if up_thrust_hitbox:
		up_thrust_hitbox.get_node("CollisionShape2D").disabled = true
		
func down_thrust_enable():
	velocity.y = blackboard.down_thrust_force * blackboard.gravity_dir.y
	if down_thrust_hitbox:
		down_thrust_hitbox.get_node("CollisionShape2D").disabled = false
		
func down_thrust_disable():
	if down_thrust_hitbox:
		down_thrust_hitbox.get_node("CollisionShape2D").disabled = true
		
func punch_enable():
	if punch_hitbox:
		punch_hitbox.get_node("CollisionShape2D").disabled = false
		
func punch_disable():
	if punch_hitbox:
		punch_hitbox.get_node("CollisionShape2D").disabled = true
		
func kick_enable():
	if kick_hitbox:
		kick_hitbox.get_node("CollisionShape2D").disabled = false
		
func kick_disable():
	if kick_hitbox:
		kick_hitbox.get_node("CollisionShape2D").disabled = true

func roll():
	if not blackboard.can_roll:
		return Vector2.ZERO
	var direction = Vector2.ZERO
	if input.double_tap_direction != input.DOUBLE_TAP_DIRECTION.NONE:
		direction = input.get_double_tap_direction()
		input.double_tap_direction = input.DOUBLE_TAP_DIRECTION.NONE
	else:
		direction = input.get_aim_direction()
	velocity.x += direction.x * blackboard.roll_speed
	return direction

func can_roll():
	if not blackboard.can_roll or not is_on_floor():
		return false
	return true

func slide():
	var direction = Vector2.ZERO
	if input.double_tap_direction != input.DOUBLE_TAP_DIRECTION.NONE:
		direction = input.get_double_tap_direction()
		input.double_tap_direction = input.DOUBLE_TAP_DIRECTION.NONE
	else:
		direction = input.get_aim_direction()
	velocity.x += direction.x * blackboard.slide_speed
	return direction
	
func can_slide():
	if not blackboard.can_slide or not is_on_floor():
		return false
	return true

func is_pushing():
	if is_on_wall():
		if motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
			if blackboard.is_facing_right and input.is_pressing_right():
				return true
			elif not blackboard.is_facing_right and input.is_pressing_left():
				return true
		else:
			if input.is_pressing_right() or input.is_pressing_left() or input.is_pressing_up() or input.is_pressing_down():
				return true
	return false
	
func is_trying_to_push():
	if motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		if blackboard.is_facing_right and input.is_pressing_right():
			return true
		elif not blackboard.is_facing_right and input.is_pressing_left():
			return true
	else:
		if input.is_pressing_right() or input.is_pressing_left() or input.is_pressing_up() or input.is_pressing_down():
			return true
	return false
	
func wall_jump():
	var direction = 0
	if blackboard.wall_cling_point.x > global_position.x:
		direction = 1
	else:
		direction = -1
	velocity.y = - blackboard.jump_force * blackboard.gravity_dir.y
	velocity.x = blackboard.jump_force * -direction
	blackboard.wall_cling_point = Vector2.ZERO

func set_flip_to_input_direction():
	if input.is_pressing_right():
		animated_sprite.flip_h = false
	elif input.is_pressing_left():
		animated_sprite.flip_h = true

func reverse_flip():
	if animated_sprite.flip_h:
		animated_sprite.flip_h = false

func is_wall_clinging():
	if blackboard.can_wall_cling and is_on_wall():
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			if collider is TileMapLayer:
				blackboard.wall_cling_point = collision.get_position()
				if input.is_pressing_right() and blackboard.is_facing_right:
					return blackboard.wall_cling_point
				elif input.is_pressing_left() and not blackboard.is_facing_right:
					return blackboard.wall_cling_point
	return null

func is_dangling():
	if not is_on_floor():
		return false
	var res1 = false
	if dangling_raycast:
		res1 = not dangling_raycast.is_colliding()
	return res1

func take_damage(amount: int):
	if not blackboard.is_alive:
		return
	if state_machine:
		state_machine.dispatch("damage")
	character_sheet.take_damage(amount)
	pulse_health()
	if character_sheet.health <= 0:
		if state_machine:
			state_machine.dispatch("death")

func pulse_health():
	if not blackboard.is_alive:
		return
	if material:
		# One shot
		material.set_shader_parameter("pulse_mode", 1)
		material.set_shader_parameter("pulse_cycle_speed", 10.0)
		await get_tree().create_timer(0.5).timeout
		material.set_shader_parameter("pulse_mode", 0)
		material.set_shader_parameter("pulse_cycle_speed", 1.0)

		# Continuous
		var health_percent = float(character_sheet.health) / float(character_sheet.max_health)
		if health_percent < 0.5:
			var pulse_cycle_speed = health_percent * 10.0
			material.set_shader_parameter("pulse_mode", 1)
			material.set_shader_parameter("pulse_cycle_speed", pulse_cycle_speed)
		else:
			material.set_shader_parameter("pulse_mode", 0)
			material.set_shader_parameter("pulse_cycle_speed", 1.0)

func apply_knockback(direction: Vector2):
	velocity = Vector2.ZERO
	blackboard.velocity = direction * blackboard.knockback_force
	velocity = blackboard.velocity
	if move_and_slide():
		handle_collisions()

func is_on_ladder():
	if ladder_raycast:
		return ladder_raycast.is_colliding()
	return false

func is_ledge_grabbing():
	if ledge_grab_raycast:
		if not ledge_grab_raycast.is_colliding():
			if is_on_wall():
					if input.is_pressing_right() and blackboard.is_facing_right:
						return true
					elif input.is_pressing_left() and not blackboard.is_facing_right:
						return true
	return false

func play_collide_effect(effect_name: String, col: KinematicCollision2D):
	pass
	#if collide_effect:
		#var effect = collide_effect.instantiate()
		#effect.global_position = col.get_position()
		#get_tree().current_scene.add_child(effect)

func smash_down_enable():
	velocity.y = blackboard.smash_down_force * blackboard.gravity_dir.y
	if smash_down_hitbox:
		smash_down_hitbox.get_node("CollisionShape2D").disabled = false
		
func smash_down_disable():
	if smash_down_hitbox:
		smash_down_hitbox.get_node("CollisionShape2D").disabled = true

func can_crouch():
	return blackboard.can_crouch
	
func can_smash_down():
	return blackboard.can_smash_down
	
func can_punch():
	return blackboard.can_punch
	
func can_kick():
	return blackboard.can_kick

func drop_down():
	position.y += 2

func get_direction_name():
	if motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		return ""
	var v: Vector2 = input.get_movement_direction()
	if v.x != 0:
		blackboard.facing_direction = Vector2.RIGHT if v.x > 0 else Vector2.LEFT
	elif v.y != 0:
		blackboard.facing_direction = Vector2.UP if v.y < 0 else Vector2.DOWN
	match blackboard.facing_direction:
		Vector2.RIGHT:
			return 'Right'
		Vector2.UP:
			return 'Up'
		Vector2.DOWN:
			return 'Down'
	return 'Right'
