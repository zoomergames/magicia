extends CanvasLayer

func _ready() -> void:
	add_to_group("inventory_ui")
	update_all_slots()

func update_all_slots() -> void:
	print("=== ОБНОВЛЕНИЕ СЛОТОВ ИНВЕНТАРЯ ===")
	for i in range(7):
		var slot_button = get_node("VBoxContainer/Slot" + str(i))
		var item_data = Global.inventory[i]
		print("Слот ", i, ": ", item_data)
		if item_data:
			print("  -> item_name: ", item_data.item_name)
		
		if item_data and item_data.icon:
			slot_button.icon = item_data.icon
			slot_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		else:
			slot_button.icon = null
	print("=== КОНЕЦ ОБНОВЛЕНИЯ ===")

func _on_slots_container_mouse_entered() -> void:
	Global.is_pointer_over_ui = true

func _on_slots_container_mouse_exited() -> void:
	Global.is_pointer_over_ui = false

func on_slot_hovered(slot_index: int) -> void:
	var item_data: Resource = Global.inventory[slot_index]
	if item_data != null:
		var text_info: String = ItemDatabase.get_item_tooltip_text(item_data)
		if Global.tooltip_node:
			Global.tooltip_node.show_tooltip(text_info)

func on_slot_exited() -> void:
	if Global.tooltip_node:
		Global.tooltip_node.hide_tooltip()


# СЛОТ 1
func _on_slot_0_mouse_entered() -> void:
	on_slot_hovered(0)
func _on_slot_0_mouse_exited() -> void:
	on_slot_exited()


func _on_slot_1_mouse_entered() -> void:
	on_slot_hovered(1)
func _on_slot_1_mouse_exited() -> void:
	on_slot_exited()


func _on_slot_2_mouse_entered() -> void:
	on_slot_hovered(2)
func _on_slot_2_mouse_exited() -> void:
	on_slot_exited()


func _on_slot_3_mouse_entered() -> void:
	on_slot_hovered(3)
func _on_slot_3_mouse_exited() -> void:
	on_slot_exited()


func _on_slot_4_mouse_entered() -> void:
	on_slot_hovered(4)
func _on_slot_4_mouse_exited() -> void:
	on_slot_exited()


func _on_slot_5_mouse_entered() -> void:
	on_slot_hovered(5)
func _on_slot_5_mouse_exited() -> void:
	on_slot_exited()


func _on_slot_6_mouse_entered() -> void:
	on_slot_hovered(6)
func _on_slot_6_mouse_exited() -> void:
	on_slot_exited()
