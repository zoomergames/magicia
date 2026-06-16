extends PanelContainer

@onready var label: RichTextLabel = %DescriptionLabel

func _ready() -> void:
	visible = false
	Global.tooltip_node = self
	
func _process(_delta: float) -> void:
	if visible:
		var mouse_pos = get_global_mouse_position()
		var screen_size = get_viewport_rect().size
		
		# Базовый отступ, чтобы тултип не прилипал прямо к курсору
		var offset = Vector2(15, 15)
		
		# Рассчитываем идеальную позицию (по умолчанию: правее и ниже мышки)
		var target_pos = mouse_pos + offset
		
		# 1. ПРОВЕРКА ПО ВЕРТИКАЛИ (НИЖНЯЯ ГРАНИЦА)
		# Если позиция + высота тултипа больше, чем высота экрана:
		if target_pos.y + size.y > screen_size.y:
			# Перекидываем тултип НАВЕРХ мышки (вычитаем его высоту и отступ)
			target_pos.y = mouse_pos.y - size.y - 15
			
		# 2. ПРОВЕРКА ПО ГОРИЗОНТАЛИ (ПРАВАЯ ГРАНИЦА - на будущее)
		# Если тултип слишком длинный и улетает вправо за экран:
		if target_pos.x + size.x > screen_size.x:
			# Перекидываем его СЛЕВА от мышки
			target_pos.x = mouse_pos.x - size.x - 15
			
		# Применяем высчитанную позицию
		global_position = target_pos
		
func show_tooltip(text: String) -> void:
	label.text = text
	reset_size() # Заставит контейнер мгновенно пересчитать свой размер под новый текст
	visible = true
	
func hide_tooltip() -> void:
	visible = false
