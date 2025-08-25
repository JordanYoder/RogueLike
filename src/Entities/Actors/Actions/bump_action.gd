class_name BumpAction
extends ActionWithDirection


func perform() -> bool:
	# If there is a target perform melee action - if not move to location instead
	if get_target_actor():
		return MeleeAction.new(entity, offset.x, offset.y).perform()
	else:
		return MovementAction.new(entity, offset.x, offset.y).perform()
