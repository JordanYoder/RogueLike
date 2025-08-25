class_name MovementAction
extends ActionWithDirection


func perform() -> bool:
	# Get the intended destination position for this entity
	var destination: Vector2i = get_destination()
	var map_data: MapData = get_map_data()
	var destination_tile: Tile = map_data.get_tile(destination)
	
	# Destination is blocked
	if not destination_tile or not destination_tile.is_walkable() or get_blocking_entity_at_destination():
		if entity == get_map_data().player:
			MessageLog.send_message("That way is blocked.", GameColors.IMPOSSIBLE)
		return false
		
	# Move entity
	entity.move(offset)
	
	return true
