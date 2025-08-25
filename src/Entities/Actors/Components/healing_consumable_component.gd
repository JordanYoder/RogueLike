class_name HealingConsumableComponent
extends ConsumableComponent

var amount: int


func _init(definition: HealingConsumableComponentDefinition) -> void:
	amount = definition.healing_amount


# Activate healing item
func activate(action: ItemAction) -> bool:
	var consumer: Entity = action.entity
	
	# Heal the player
	var amount_recovered: int = consumer.fighter_component.heal(amount)
	
	# If healed display message and consume item
	if amount_recovered > 0:
		MessageLog.send_message(
			"You consume the %s, and recover %d HP!" % [entity.get_entity_name(), amount_recovered],
			GameColors.HEALTH_RECOVERED
		)
		
		# Remove item from entity's inventory
		consume(consumer)
		
		return true
	
	# Exit if no health is restored
	MessageLog.send_message("Your health is already full.", GameColors.IMPOSSIBLE)
	return false
