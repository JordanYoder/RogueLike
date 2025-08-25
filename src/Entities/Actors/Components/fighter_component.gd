class_name FighterComponent
extends Component

signal hp_changed(hp, max_hp)

var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			var die_silently := false
			if not is_inside_tree():
				die_silently = true
				await ready
			die(not die_silently)
var base_defense: int
var base_power: int
var defense: int: 
	get:
		return base_defense + get_defense_bonus()
var power: int: 
	get:
		return base_power + get_power_bonus()


var death_texture: Texture
var death_color: Color


func _init(definition: FighterComponentDefinition) -> void:
	max_hp = definition.max_hp
	hp = definition.max_hp
	base_defense = definition.defense
	base_power = definition.power
	death_texture = definition.death_texture
	death_color = definition.death_color


# Heal
func heal(amount: int) -> int:
	
	# Already at max HP
	if hp == max_hp:
		return 0
	
	# Healing calculation
	var new_hp_value: int = hp + amount
	
	# Healing above max hp is capped at max hp
	if new_hp_value > max_hp:
		new_hp_value = max_hp
	
	# Health recovered
	var amount_recovered: int = new_hp_value - hp
	
	# Set current HP
	hp = new_hp_value
	
	return amount_recovered


# Adjust HP after damage taken
func take_damage(amount: int) -> void:
	hp -= amount


# Death
func die(trigger_side_effects := true) -> void:
	var death_message: String
	var death_message_color: Color
	
	# If the player dies
	if get_map_data().player == entity:
		death_message = "You died!"
		death_message_color = GameColors.PLAYER_DIE
		SignalBus.player_died.emit()
		
	# If an entity other than the player dies
	else:
		death_message = "%s is dead!" % entity.get_entity_name()
		death_message_color = GameColors.ENEMY_DIE
	
	# Trigger XP increase and message (if applicable)
	if trigger_side_effects:
		MessageLog.send_message(death_message, death_message_color)
		get_map_data().player.level_component.add_xp(entity.level_component.xp_given)
	
	# Modify the entity to reflect that it has 'died'
	entity.texture = death_texture
	entity.modulate = death_color
	entity.ai_component.queue_free()
	entity.ai_component = null
	entity.entity_name = "Remains of %s" % entity.entity_name
	entity.blocks_movement = false
	entity.type = Entity.EntityType.CORPSE
	get_map_data().unregister_blocking_entity(entity)


# Return defense bonus
func get_defense_bonus() -> int:
	if entity.equipment_component:
		return entity.equipment_component.get_defense_bonus()
	return 0


# Return power bonus
func get_power_bonus() -> int:
	if entity.equipment_component:
		return entity.equipment_component.get_power_bonus()
	return 0


func get_save_data() -> Dictionary:
	return {
		"max_hp": max_hp,
		"hp": hp,
		"power": base_power,
		"defense": base_defense
	}


func restore(save_data: Dictionary) -> void:
	max_hp = save_data["max_hp"]
	hp = save_data["hp"]
	base_power = save_data["power"]
	base_defense = save_data["defense"]
