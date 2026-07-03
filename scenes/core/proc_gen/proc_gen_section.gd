class_name ProcGenSection extends Node2D

var parent: ProcGenChunker

var width: int = 0
var height: int = 0

var player: CharacterController

var original_position: Vector2

var middle_chunk: ProcGenChunk
var middle_chunk_position: Vector2
var middle_chunk_middle_position: Vector2
var middle_chunk_left_position: Vector2
var middle_chunk_right_position: Vector2
var middle_chunk_top_position: Vector2
var middle_chunk_bottom_position: Vector2

var chunks: Array[ProcGenChunk] = []

var entered: bool = false
var middle_entered: bool = false

signal section_enter(section: ProcGenSection, pos: Vector2, dir: Vector2)
signal section_exit(section: ProcGenSection, pos: Vector2, dir: Vector2)
signal middle_enter(section: ProcGenSection, pos: Vector2, dir: Vector2)
signal middle_exit(section: ProcGenSection, pos: Vector2, dir: Vector2)

func _ready():
	parent = get_parent()
	
func init(_player, _position: Vector2, scene_paths: Array[String]):
	player = _player
	original_position = Vector2.ZERO
	global_position = _position
	for c in get_children():
		c.queue_free()
	width = 0
	height = 0
	var tmp_pos = original_position
	for scene_path in scene_paths:
		
		var node_resource = load(scene_path)
		var chunk = node_resource.instantiate()
		if chunk is ProcGenChunk:
			chunk.position = tmp_pos
			add_child(chunk)
			chunks.append(chunk)
			
		if parent.generation_direction == ProcGenChunker.GenerationDirection.X:
			width += chunk.width
			tmp_pos.x += chunk.width
		elif parent.generation_direction == ProcGenChunker.GenerationDirection.Y:
			height += chunk.height
			tmp_pos.y += chunk.height
		
	if width == 0:
		width = chunks[0].width
	if height == 0:
		height = chunks[0].height
	
	@warning_ignore("integer_division")
	var mid_index = chunks.size() / 2
	middle_chunk = chunks[mid_index]
	middle_chunk_position = middle_chunk.position
	
	@warning_ignore("integer_division")
	var half_width = (middle_chunk.width / 2)
	@warning_ignore("integer_division")
	var half_height = (middle_chunk.height / 2)
	
	match parent.generation_direction:
		ProcGenChunker.GenerationDirection.X:
			middle_chunk_middle_position = Vector2(middle_chunk_position.x + half_width, 0)
			middle_chunk_left_position = Vector2(middle_chunk_middle_position.x - half_width, 0)
			middle_chunk_right_position = Vector2(middle_chunk_middle_position.x + half_width, 0)
			middle_chunk_top_position = Vector2.ZERO
			middle_chunk_bottom_position = Vector2.ZERO
		ProcGenChunker.GenerationDirection.Y:
			middle_chunk_middle_position = Vector2(0, middle_chunk_position.y + half_height)
			middle_chunk_top_position = Vector2(0, middle_chunk_middle_position.y - half_height)
			middle_chunk_bottom_position = Vector2(0, middle_chunk_middle_position.y + half_height)
			middle_chunk_left_position = Vector2.ZERO
			middle_chunk_right_position = Vector2.ZERO
		ProcGenChunker.GenerationDirection.BOTH:
			pass

func debug():
	print("width", width)
	print("height", height)
	print("middle_chunk", middle_chunk)
	print("middle_chunk_middle_position", middle_chunk_middle_position)
	print("middle_chunk_left_position", middle_chunk_left_position)
	print("middle_chunk_right_position", middle_chunk_right_position)
	print("middle_chunk_top_position", middle_chunk_top_position)
	print("middle_chunk_bottom_position", middle_chunk_bottom_position)
	
func _process(_delta: float) -> void:
	check_bounds()

func check_bounds():	
	if not player:
		return
	match parent.generation_direction:
		ProcGenChunker.GenerationDirection.X:	
			if entered:		
				if player.position.x < position.x or player.position.x > position.x + width:
					entered = false
					var dir = -1 if player.position.x < position.x else 1
					section_exit.emit(self, player.position, Vector2(dir, 0))
					return
			else:
				if player.position.x > position.x and player.position.x < position.x + width:
					entered = true
					var dir = -1 if player.position.x < position.x + (width / 2.0) else 1
					section_enter.emit(self, player.position, Vector2(dir, 0))
					return
			if middle_entered:
				if player.position.x < position.x + middle_chunk_left_position.x or player.position.x > position.x + middle_chunk_right_position.x:
					middle_entered = false
					var dir = -1 if player.position.x < position.x + middle_chunk_middle_position.x else 1
					middle_exit.emit(self, player.position, Vector2(dir, 0))
					return
			else:
				if player.position.x > position.x + middle_chunk_left_position.x and player.position.x < position.x + middle_chunk_right_position.x:
					middle_entered = true
					var dir = -1 if player.position.x < position.x + middle_chunk_middle_position.x else 1
					middle_enter.emit(self, player.position, Vector2(dir, 0))
					return
		ProcGenChunker.GenerationDirection.Y:	
			if entered:		
				if player.position.y < position.y or player.position.y > position.y + height:
					entered = false
					var dir = -1 if player.position.y < position.y else 1
					section_exit.emit(self, player.position, Vector2(0, dir))
					return
			else:
				if player.position.y > position.y and player.position.y < position.y + height:
					entered = true
					var dir = -1 if player.position.y < position.y + (width / 2.0) else 1
					section_enter.emit(self, player.position, Vector2(0, dir))
					return
			if middle_entered:
				if player.position.y < position.y + middle_chunk_top_position.y or player.position.y > position.y + middle_chunk_bottom_position.y:
					middle_entered = false
					var dir = -1 if player.position.y < position.y + middle_chunk_middle_position.y else 1
					middle_exit.emit(self, player.position, Vector2(0, dir))
					return
			else:
				if player.position.y > position.y + middle_chunk_top_position.y and player.position.y < position.y + middle_chunk_bottom_position.y:
					middle_entered = true
					var dir = -1 if player.position.y < position.x + middle_chunk_middle_position.x else 1
					middle_enter.emit(self, player.position, Vector2(0, dir))
					return
