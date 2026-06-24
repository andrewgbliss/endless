class_name BiomeTileRepeater extends Node2D

@export var size: int = 16
@export var size_scale: int = 16
@export var player: CharacterController

var biome_tiles_scenes: Array[String] = [
	"res://scenes/core/proc_gen/biome_tiles.tscn",
	"res://scenes/core/proc_gen/biome_tiles.tscn",
	"res://scenes/core/proc_gen/biome_tiles.tscn",
	"res://scenes/core/proc_gen/biome_tiles.tscn",
	"res://scenes/core/proc_gen/biome_tiles.tscn"
]

var biome_tiles: Array[BiomeTiles]
var current_position: Vector2
var previous_position: Vector2

var width = size * size_scale
var height = size * size_scale

func _ready() -> void:
	generate_biome_tiles()
	_position_tiles()
	
func generate_biome_tiles():
	current_position = Vector2.ZERO
	previous_position = Vector2.ZERO
	biome_tiles.clear()
	for scene_path in biome_tiles_scenes:
		var node_resource = load(scene_path)
		var node = node_resource.instantiate()
		if node is BiomeTiles:
			biome_tiles.append(node)
			add_child(node)
						
func _position_tiles():
	current_position = Vector2(previous_position.x - width * 2, 0)
	for biome_tile in biome_tiles:
		biome_tile.position = current_position
		current_position.x += width
		
func _process(_delta: float) -> void:
	if current_position != player.position:
		current_position = player.position
		if current_position.x > previous_position.x + width:
			pop_left_append_right()
		elif current_position.x < previous_position.x:
			pop_right_append_left()

func pop_left_append_right():
	var node = biome_tiles.pop_front()
	biome_tiles.append(node) 
	previous_position = biome_tiles[2].position
	_position_tiles()
	
func pop_right_append_left():
	var node = biome_tiles.pop_back()
	biome_tiles.push_front(node) 
	previous_position = biome_tiles[2].position
	_position_tiles()
