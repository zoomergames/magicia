extends CanvasLayer

# ТЕКСТУРЫ ДЛЯ СТИЛИЗАЦИИ СЛОТОВ (Перетащите спрайты в инспекторе)
@export var normal_slot_texture: Texture2D    # Обычный пустой слот
@export var hover_slot_texture: Texture2D     # Слот при наведении курсора
@export var active_slot_texture: Texture2D    # Выбранный/активный слот

func _ready() -> void:
	add_to_group("inventory_ui")
	update_all_slots()

# ОСНОВНАЯ ФУНКЦИЯ ОБНОВЛЕНИЯ ИНТЕРФЕЙСА
func update_all_slots() -> void:
	print("=== ОБНОВЛЕНИЕ СЛОТОВ ИНВЕНТАРЯ ===")
	for i in range(7):
		var slot_button = get_node("VBoxContainer/Slot" + str(i)) as Button
		var item_data = Global.inventory[i]
		
		# 1. Отрисовка иконки предмета внутри слота
		if item_data and item_data.icon:
			slot_button.icon = item_data.icon
			slot_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		else:
			slot_button.icon = null
		
		# 2. Стилизация рамок (Обычный vs Активный выбранный слот)
		if i == Global.active_slot_index:
			# Если этот слот выбран текущим — принудительно ставим ему активную рамку во всех состояниях
			_apply_button_styles(slot_button, active_slot_texture, active_slot_texture)
		else:
			# Если слот не выбран — ставим обычную текстуру и текстуру наведения (hover)
			_apply_button_styles(slot_button, normal_slot_texture, hover_slot_texture)
			
	print("=== КОНЕЦ ОБНОВЛЕНИЯ ===")

# ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ ПРИМЕНЕНИЯ СТИЛЕЙ К КНОПКЕ
func _apply_button_styles(button: Button, base_tex: Texture2D, hover_tex: Texture2D) -> void:
	if base_tex:
		var sb_normal = StyleBoxTexture.new()
		sb_normal.texture = base_tex
		button.add_theme_stylebox_override("normal", sb_normal)
		button.add_theme_stylebox_override("pressed", sb_normal) # Текстура при удержании клика
		button.add_theme_stylebox_override("focused", sb_normal) # Текстура фокуса
	
	if hover_tex:
		var sb_hover = StyleBoxTexture.new()
		sb_hover.texture = hover_tex
		button.add_theme_stylebox_override("hover", sb_hover)

# ОБЩАЯ ЛОГИКА ВЫБОРА СЛОТА
func _select_slot(index: int) -> void:
	Global.active_slot_index = index
	update_all_slots()
	
	# Автоматически просим игрока сменить оружие в руках под новый слот
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("change_hand_weapon"):
		player.change_hand_weapon()

# ЛОГИКА ТУЛТИПОВ (ОПТИМИЗИРОВАННАЯ)
func _on_slot_hovered(slot_index: int) -> void:
	var item_data: Resource = Global.inventory[slot_index]
	if item_data != null:
		var text_info: String = ItemDatabase.get_item_tooltip_text(item_data)
		if Global.tooltip_node:
			Global.tooltip_node.show_tooltip(text_info)

func _on_slot_exited() -> void:
	if Global.tooltip_node:
		Global.tooltip_node.hide_tooltip()

# =================================================================
# СИГНАЛЫ ДЛЯ НАВЕДЕНИЯ МЫШКИ И КЛИКОВ (ПОДКЛЮЧИТЕ ИХ В РЕДАКТОРЕ)
# =================================================================

# СЛОТ 0
func _on_slot_0_mouse_entered() -> void: _on_slot_hovered(0)
func _on_slot_0_mouse_exited() -> void: _on_slot_exited()
func _on_slot_0_pressed() -> void: _select_slot(0)

# СЛОТ 1
func _on_slot_1_mouse_entered() -> void: _on_slot_hovered(1)
func _on_slot_1_mouse_exited() -> void: _on_slot_exited()
func _on_slot_1_pressed() -> void: _select_slot(1)

# СЛОТ 2
func _on_slot_2_mouse_entered() -> void: _on_slot_hovered(2)
func _on_slot_2_mouse_exited() -> void: _on_slot_exited()
func _on_slot_2_pressed() -> void: _select_slot(2)

# СЛОТ 3
func _on_slot_3_mouse_entered() -> void: _on_slot_hovered(3)
func _on_slot_3_mouse_exited() -> void: _on_slot_exited()
func _on_slot_3_pressed() -> void: _select_slot(3)

# СЛОТ 4
func _on_slot_4_mouse_entered() -> void: _on_slot_hovered(4)
func _on_slot_4_mouse_exited() -> void: _on_slot_exited()
func _on_slot_4_pressed() -> void: _select_slot(4)

# СЛОТ 5
func _on_slot_5_mouse_entered() -> void: _on_slot_hovered(5)
func _on_slot_5_mouse_exited() -> void: _on_slot_exited()
func _on_slot_5_pressed() -> void: _select_slot(5)

# СЛОТ 6
func _on_slot_6_mouse_entered() -> void: _on_slot_hovered(6)
func _on_slot_6_mouse_exited() -> void: _on_slot_exited()
func _on_slot_6_pressed() -> void: _select_slot(6)
