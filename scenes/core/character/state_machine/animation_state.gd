class_name AnimationState extends State

var animation_name: String = ""
var play_on_enter: bool = true
var wait_for_animation_finished: bool = false
var is_animation_finished: bool = false

func _init(wait: bool = false, _play_on_enter: bool = true):
	wait_for_animation_finished = wait
	play_on_enter = _play_on_enter

func enter() -> void:
	super.enter()
	if play_on_enter:
		play_animation(wait_for_animation_finished)
		
func update_move_animation():
	if parent.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_GROUNDED:
		return
	play_animation()

func play_animation(wait_for_finished: bool = false):
	if not animation_name or not parent.animated_sprite:
		return
	is_animation_finished = false
	var anim_name = animation_name + parent.get_direction_name()
	if parent.animated_sprite.sprite_frames.has_animation(anim_name):
		parent.animated_sprite.play(anim_name)
	if wait_for_finished:
		await parent.animated_sprite.animation_finished
		is_animation_finished = true
		return
	is_animation_finished = true
	
func play_animation_name(an: String, wait_for_finished: bool = false):
	if not an or not parent.animated_sprite:
		return
	is_animation_finished = false
	var anim_name = an + parent.get_direction_name()
	parent.animated_sprite.play(anim_name)
	if wait_for_finished:
		await parent.animated_sprite.animation_finished
		is_animation_finished = true
		return
	is_animation_finished = true
