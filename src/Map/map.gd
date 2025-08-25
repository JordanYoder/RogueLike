class_name Map
extends Node2D

signal dungeon_floor_changed(floor)

var map_data: MapData

@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView



func _ready() -> void:
	SignalBus.player_descended.connect(next_floor)


# Generate the map data
func generate(player: Entity, current_floor: int = 1) -> void:
	map_data = dungeon_generator.generate_dungeon(player, current_floor)
	
	# If new instance of map data, make sure entities are placed in this new instance and not an older instance
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
		
	# Place the map data
	_place_tiles()
	_place_entities()
	dungeon_floor_changed.emit(current_floor)


# Generate and move to next floor of map
func next_floor() -> void:
	
	# Get the player from the map data and remove it from that map's entities
	var player: Entity = map_data.player
	entities.remove_child(player)
	
	# Delete all entities in the map data
	for entity in entities.get_children():
		entity.queue_free()
	for tile in tiles.get_children():
		tile.queue_free()
	
	# Generate the new floor
	generate(player, map_data.current_floor + 1)
	
	# Assign player to the new floor
	player.get_node("Camera2D").make_current()
	field_of_view.reset_fov()
	update_fov(player.grid_position)


# Loads game data
func load_game(player: Entity) -> bool:
	# Create a fresh instance of map data
	map_data = MapData.new(0, 0, player)
	map_data.entity_placed.connect(entities.add_child)
	
	# Attempts to load and restore state
	if not map_data.load_game():
		return false  # Failed load
	_place_tiles()
	_place_entities()
	dungeon_floor_changed.emit(map_data.current_floor)
	
	return true  # Successfull load


# Update the FOV for both the player and all the entities that are visible to the player
func update_fov(player_position: Vector2i) -> void:
	field_of_view.update_fov(map_data, player_position, 8)
	
	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_in_view


# Places the tiles
func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)


# Places the entities
func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)
