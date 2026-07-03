class_name ProcGenChunker extends Node2D

enum ChunkType { SAFE, EASY, MEDIUM, HARD, BRUTAL, BONUS }
enum GenerationDirection { X, Y, BOTH }

@export var generation_direction: GenerationDirection = GenerationDirection.X
@export var player: CharacterController

var spawn_position: Vector2
var original_position: Vector2

# Sections
var current_section: ProcGenSection
var sections_visited = {}
var section_count: int = 1
var section_threshold: int = 1
var section_stack: Array[ProcGenSection] = []
var max_sections: int = 2

# Chunks
var biome_map_path = "res://scenes/game/proc_gen/biomes/biome_map.json"
var biome_data
var current_biome_path
var chunk_map

# Level
var level: int = 0

func _ready() -> void:
	init()
	
func init():
	load_biomes()
	load_chunk_map("x_blocks")
	spawn_position = player.position
	original_position = global_position
	
	current_section = create_section(original_position)
	
	var tmp_pos = original_position
	
	if generation_direction == GenerationDirection.X:
		tmp_pos.x -= (current_section.width / 2.0)
	elif generation_direction == GenerationDirection.Y:
		tmp_pos.y -= (current_section.height / 2.0)

	current_section.global_position = tmp_pos
	
	await get_tree().create_timer(0.1).timeout
	connect_pit_signals()
	
func load_biomes():
	biome_data = FilesUtil.restore(biome_map_path)
	
func load_chunk_map(name: String):
	if not biome_data.has(name):
		print("Biome doesn't exist")
		return
	current_biome_path = biome_data[name]
	chunk_map = FilesUtil.restore(current_biome_path + "/chunk_map.json");
	
func create_section(section_position: Vector2):
	if sections_visited.has(section_position):
		return sections_visited[section_position]
		
	var section = ProcGenSection.new()
	sections_visited[section_position] = section
	section.global_position = section_position
	add_child(section)
	section.init(
		player, 
		section_position,
		pick_random_chunks()
	)
	section.section_enter.connect(_on_section_enter)
	section.section_exit.connect(_on_section_exit)
	section.middle_enter.connect(_on_middle_enter)
	section.middle_exit.connect(_on_middle_exit)
	
	section_stack.append(section)
	
	if len(section_stack) > max_sections:
		clean_up_sections()
		
	return section
	
func clean_up_sections():
	var front = section_stack.pop_front()
	front.queue_free()
	
func connect_pit_signals():
	var pits = get_tree().get_nodes_in_group("pit_game_over")
	for p in pits:
		if p is PitGameOver:
			if p.area.body_entered.is_connected(_on_body_entered_pit):
				p.area.body_entered.disconnect(_on_body_entered_pit)
			p.area.body_entered.connect(_on_body_entered_pit)
	
func _on_body_entered_pit(_body):
	#player.position = spawn_position
	get_tree().reload_current_scene()
	
func _on_section_enter(section: ProcGenSection, pos: Vector2, dir: Vector2):
	#print("Island enter", pos, dir)
	current_section = section
	pass
	
func _on_section_exit(section: ProcGenSection, pos: Vector2, dir: Vector2):
	#print("Island exit", pos, dir)
	pass
	
func _on_middle_enter(section: ProcGenSection, pos: Vector2, dir: Vector2):
	#print("Middle enter", pos, dir)
	pass
	
func _on_middle_exit(section: ProcGenSection, pos: Vector2, dir: Vector2):
	#print("Middle exit", pos, dir)
	if generation_direction == GenerationDirection.X:
		if dir.x > 0:
			create_right_section()
		elif dir.x < 0:
			create_left_section()
	elif generation_direction == GenerationDirection.Y:
		if dir.y > 0:
			create_bottom_section()
		elif dir.y < 0:
			create_top_section()
	
func create_left_section():
	var new_pos = Vector2(current_section.global_position.x - current_section.width, 0)
	create_section(new_pos)
	section_count += 1
	if section_count > section_threshold:
		advance_level()
		section_count = 1
		section_threshold *= 2
	await get_tree().create_timer(0.1).timeout
	connect_pit_signals()
	
func create_right_section():
	var new_pos = Vector2(current_section.global_position.x + current_section.width, 0)
	create_section(new_pos)
	section_count += 1
	if section_count > section_threshold:
		advance_level()
		section_count = 1
		section_threshold *= 2
	await get_tree().create_timer(0.1).timeout
	connect_pit_signals()
	
func create_top_section():
	var new_pos = Vector2(0, current_section.global_position.y - current_section.height)
	create_section(new_pos)
	section_count += 1
	if section_count > section_threshold:
		advance_level()
		section_count = 0
		section_threshold *= 2
	
func create_bottom_section():
	var new_pos = Vector2(0, current_section.global_position.y + current_section.height)
	create_section(new_pos)
	section_count += 1
	if section_count > section_threshold:
		advance_level()
		section_count = 0
		section_threshold *= 2

func pick_weighted_random(weights: Array[float]) -> Array[int]:
	var res: Array[int] = []

	var total_weight: float = 0.0
	for i in len(weights):
		total_weight += weights[i]

	for i in 5:
		var random_value: float = randf() * total_weight
		var cumulative: float = 0.0

		for w in len(weights):
			cumulative += weights[w]
			if random_value < cumulative:
				res.append(w)
				break

	return res
	
func pick_from_index(arr: Array, index: Array[int]) -> Array:
	var res = []
	for i in index:
		res.append(arr[i])
	return res
	
func get_selectable_weights(possible: Dictionary) -> Array[float]:
	var res: Array[float] = []
	for c in possible:
		res.append(float(possible[c]['selectable']))
	return res
	
func get_possible_chunks(possible_chunks: Dictionary) -> Array:
	var res = []
	for c in possible_chunks:
		res.append(c)
	return res

func pick_random_chunks() -> Array[String]:
	var res: Array[String] = []
	var possible_chunks = chunk_map["levels"][level]
	
	var possible = get_possible_chunks(possible_chunks)
	var weights = get_selectable_weights(possible_chunks)
	
	var indexes = pick_weighted_random(weights)
	var results = pick_from_index(possible, indexes)
		
	for c in results:
		res.append(current_biome_path + "/" + c + ".tscn")

	return res
	
func advance_level():
	level += 1
