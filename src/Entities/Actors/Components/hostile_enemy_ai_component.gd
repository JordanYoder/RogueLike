class_name HostileEnemyAIComponent
extends BaseAIComponent


var path: Array = []

func perform() -> void:
	var target: Entity = get_map_data().player
	var target_grid_position: Vector2i = target.grid_position
	var offset: Vector2i = target_grid_position - entity.grid_position
	var distance: int = max(abs(offset.x), abs(offset.y))
	
	if get_map_data().get_tile(entity.grid_position).is_in_view:
		 # If player is within a single tile perform attack
		if distance <= 1:
			return MeleeAction.new(entity, offset.x, offset.y).perform()
		
		# If not in melee distance get the path to the player's location
		path = get_point_path_to(target_grid_position)
		
		# Remove the first entry (enemy's current tile) and get the next step (actual next move toward the player)
		path.pop_front()
	
	# If path has a value attempt to move closer to player
	if not path.is_empty():
		var destination := Vector2i(path[0])
		
		# If there is a blocker, wait a turn
		if get_map_data().get_blocking_entity_at_location(destination):
			return WaitAction.new(entity).perform()
		Vector2i(path.pop_front())
		var move_offset: Vector2i = destination - entity.grid_position
		
		# Perform movement
		return MovementAction.new(entity, move_offset.x, move_offset.y).perform()
	
	# If all else fails wait this turn
	return WaitAction.new(entity).perform()


func get_save_data() -> Dictionary:
	return {"type": "HostileEnemyAI"}
