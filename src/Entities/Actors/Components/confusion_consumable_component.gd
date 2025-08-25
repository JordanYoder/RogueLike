class_name ConfusionConsumableComponent
extends ConsumableComponent

var number_of_turns: int


func _init(definition: ConfusionConsumableComponentDefinition) -> void:
	number_of_turns = definition.number_of_turns


func activate(action: ItemAction) -> bool:
	var consumer: Entity = action.entity
	var target: Entity = action.get_target_actor()
	var map_data: MapData = consumer.map_data
	
	# Tile must be currently visible
	if not map_data.get_tile(action.target_position).is_in_view:
		MessageLog.send_message("You cannot target an area that you cannot see.", GameColors.IMPOSSIBLE)
		return false
	
	# Must select a tile with an enemy
	if not target:
		MessageLog.send_message("You must select an enemy to target.", GameColors.IMPOSSIBLE)
		return false
	
	# Cannot cast on player entity
	if target == consumer:
		MessageLog.send_message("You cannot confuse yourself!", GameColors.IMPOSSIBLE)
		return false
	
	# Apply confusion effect on entity
	MessageLog.send_message("The eyes of the %s look vacant, as it starts to stumble around!" % target.get_entity_name(), GameColors.STATUS_EFFECT_APPLIED)
	target.add_child(ConfusedEnemyAIComponent.new(number_of_turns))
	
	# Remove item from inventory
	consume(consumer)
	
	return true


func get_targeting_radius() -> int:
	return 0
