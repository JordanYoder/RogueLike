class_name PickupAction
extends Action


func perform() -> bool:
	var inventory: InventoryComponent = entity.inventory_component
	var map_data: MapData = get_map_data()
	
	# Check every item
	for item in map_data.get_items():
		
		# Entity must be standing on item to pickup item
		if entity.grid_position == item.grid_position:
			
			# Inventory is full - cannot add item to inventory
			if inventory.items.size() >= inventory.capacity:
				MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
				return false
			
			# Remove item from map so we can add to inventory
			map_data.entities.erase(item)
			item.get_parent().remove_child(item)
			
			# Add item to inventory
			inventory.items.append(item)
			MessageLog.send_message(
				"You picked up the %s!" % item.get_entity_name(),
				Color.WHITE
			)
			
			return true
	
	# Entity not standing on any item
	MessageLog.send_message("There is nothing here to pick up.", GameColors.IMPOSSIBLE)
	
	return false
