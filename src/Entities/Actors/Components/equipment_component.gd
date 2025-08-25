class_name EquipmentComponent
extends Component

signal equipment_changed

var slots := {}


# Get the defense bonus from any equipped item
func get_defense_bonus() -> int:
	var bonus = 0
	
	# Go through all items and if it is equipped add defense bonus
	for item in slots.values():
		if item.equippable_component:
			bonus += item.equippable_component.defense_bonus
	
	return bonus


# Get the power bonus from any equipped item
func get_power_bonus() -> int:
	var bonus = 0
	
		# Go through all items and if it is equipped add power bonus
	for item in slots.values():
		if item.equippable_component:
			bonus += item.equippable_component.power_bonus
	
	return bonus


func is_item_equipped(item: Entity) -> bool:
	return item in slots.values()


# Equip item
func _equip_to_slot(slot: EquippableComponent.EquipmentType, item: Entity, add_message: bool) -> void:
	var current_item = slots.get(slot)
	
	# If current equipped, unequip
	if current_item:
		_unequip_from_slot(slot, add_message)
	
	# Add to equip
	slots[slot] = item
	
	# Add message if applicable
	if add_message:
		MessageLog.send_message("You equip the %s." % item.get_entity_name(), Color.WHITE)
	
	equipment_changed.emit()


# Unequip item
func _unequip_from_slot(slot: EquippableComponent.EquipmentType, add_message: bool) -> void:
	var current_item = slots.get(slot)
	
	# Add message if applicable
	if add_message:
		MessageLog.send_message("You remove the %s." % current_item.get_entity_name(), Color.WHITE)
	
	# Remove item from equipped items
	slots.erase(slot)
	
	equipment_changed.emit()


# Toggle if item is equipped
func toggle_equip(equippable_item: Entity, add_message: bool = true) -> void:
	
	# Exit if not an equippable item
	if not equippable_item.equippable_component:
		return
	
	var slot: EquippableComponent.EquipmentType = equippable_item.equippable_component.equipment_type
	
	# Equip or unequip item
	if slots.get(slot) == equippable_item:
		_unequip_from_slot(slot, add_message)
	else:
		_equip_to_slot(slot, equippable_item, add_message)


func get_save_data() -> Dictionary:
	var equipped_indices := []
	var inventory: InventoryComponent = entity.inventory_component
	for i in inventory.items.size():
		var item: Entity = inventory.items[i]
		if is_item_equipped(item):
			equipped_indices.append(i)
	return {"equipped_indices": equipped_indices}


func restore(save_data: Dictionary) -> void:
	var equipped_indices: Array = save_data["equipped_indices"]
	var inventory: InventoryComponent = entity.inventory_component
	for i in inventory.items.size():
		if equipped_indices.any(func(index): return int(index) == i):
			var item: Entity = inventory.items[i]
			toggle_equip(item, false)
