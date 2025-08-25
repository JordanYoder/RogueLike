class_name DropItemAction
extends ItemAction


func perform() -> bool:
	# Exit if no item
	if item == null:
		return false
	
	# If an equipped item, unequip
	if entity.equipment_component and entity.equipment_component.is_item_equipped(item):
		entity.equipment_component.toggle_equip(item)
	
	# Drop item
	entity.inventory_component.drop(item)
	
	return true
