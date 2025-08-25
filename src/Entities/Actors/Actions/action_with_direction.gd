class_name ActionWithDirection
extends Action

var offset: Vector2i

# Inititialize with entity data and direction data
func _init(entity: Entity, dx: int, dy: int) -> void:
	super._init(entity)
	offset = Vector2i(dx, dy)


# Return the intended destination position for this entity
func get_destination() -> Vector2i:
	return entity.grid_position + offset


# Return if there is a blocking entity at the destination
func get_blocking_entity_at_destination() -> Entity:
	return get_map_data().get_blocking_entity_at_location(get_destination())


# Return the actor at a specific location
func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(get_destination())
