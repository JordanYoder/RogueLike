extends BaseInputHandler

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/GUI/InventorMenu/inventory_menu.tscn")

@export var reticle: Reticle


# Handles game inputs
func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
	
	if Input.is_action_just_pressed("wait"):
		action = WaitAction.new(player)
	
	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
	
	if Input.is_action_just_pressed("pickup"):
		action = PickupAction.new(player)
	
	if Input.is_action_just_pressed("drop"):
		var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
		action = DropItemAction.new(player, selected_item)
	
	if Input.is_action_just_pressed("activate"):
		action = await activate_item(player)
	
	if Input.is_action_just_pressed("look"):
		await get_grid_position(player, 0)
	
	if Input.is_action_just_pressed("descend"):
		action = TakeStairsAction.new(player)
	
	if Input.is_action_just_pressed("quit") or Input.is_action_just_pressed("ui_back"):
		action = EscapeAction.new(player)
	
	return action

# Returns an action
func activate_item(player: Entity) -> Action:
	
	# Opens the inventory menu
	var selected_item: Entity = await get_item("Select an item to use", player.inventory_component, true)
	
	# Exit if no item or cancelled
	if selected_item == null:
		return null
	
	# Default to -1, which indicates no targeting needed (for example, a healing potion)
	var target_radius: int = -1
	
	# Get the targeting radius if a consumable component
	if selected_item.consumable_component != null:
		target_radius = selected_item.consumable_component.get_targeting_radius()
		
	# If no targeting return ItemAction 
	if target_radius == -1:
		return ItemAction.new(player, selected_item)
	

	# Set up targeting reticle
	var target_position: Vector2i = await get_grid_position(player, target_radius)
	
	# If player cancels targeting
	if target_position == Vector2i(-1, -1):
		return null
	
	# Return item action
	return ItemAction.new(player, selected_item, target_position)


func get_item(window_title: String, inventory: InventoryComponent, evaluate_for_next_step: bool = false) -> Entity:
	# No items in inventory
	if inventory.items.is_empty():
		# Wait one physics frame to let UI 'settle'
		await get_tree().physics_frame
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return null
		
	# Start menu
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	
	# Get selected item
	var selected_item: Entity = await inventory_menu.item_selected
	var has_item: bool = selected_item != null
	var needs_targeting: bool = has_item and selected_item.consumable_component and selected_item.consumable_component.get_targeting_radius() != -1
	
	# If the item does need targeting and evaluate_for_next_step was true, note that we didn’t switch back to 
	# MAIN_GAME here — we intentionally stay in DUMMY so the caller (e.g., activate_item) can open the reticle and 
	# manage the rest of the flow. After targeting completes or is canceled, 
	# the caller will handle returning to MAIN_GAME.
	if not evaluate_for_next_step or not has_item or not needs_targeting:
		await get_tree().physics_frame
		get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	
	# Return item
	return selected_item


func get_grid_position(player: Entity, radius: int) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position: Vector2i = await reticle.select_position(player, radius)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_position
