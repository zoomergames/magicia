extends CanvasLayer

var regex = RegEx.new()
var old_text: String = ""

var is_mouse_inside: bool = false
@onready var panel = %Panel
var fade_tween: Tween = null

func _ready() -> void:
	Global.chat_node = $Panel/RichTextLabel
	Global.name_input_node = $NameInput
	
	# Компилируем шаблон: разрешены a-z, A-Z, 0-9, а-я, А-Я, ё, Ё
	regex.compile("^[a-zA-Z0-9а-яА-ЯёЁ]*$")
	# Подключаем сигнал: каждый раз, когда текст меняется, вызываем нашу проверку
	$NameInput.text_changed.connect(_on_name_text_changed)
	
	# Подключаем функцию отслеживания новых сообщений
	# (Мы сделаем так, чтобы Global пинал чат при каждом сообщении)
	Global.chat_message_received.connect(on_new_message)
	# При старте запускаем таймер скрытия
	reset_fade_timer()
	
	Global.log_to_chat("[color=gray][Система][/color] [color=white]Игрок явился в мир![/color]")

# Функция срабатывает при вводе КАЖДОЙ буквы
func _on_name_text_changed(new_text: String) -> void:
	# Если новый текст полностью подходит под наше правило букв и цифр
	if regex.search(new_text):
		old_text = new_text # Запоминаем его как правильный
	else:
		# Если игрок попытался ввести [ или @ или пробел — возвращаем прошлый чистый текст!
		$NameInput.text = old_text
		# Возвращаем курсор ввода в самый конец строки, чтобы не сбивать печать
		$NameInput.caret_column = old_text.length()
		
# СРАБАТЫВАЕТ, КОГДА В ЧАТ ПРИШЛО НОВОЕ СООБЩЕНИЕ
func on_new_message() -> void:
	# Если пришло сообщение — мгновенно проявляем чат
	show_chat_instantly()
	
	# Если мышка НЕ внутри панели и диалога нет — запускаем плавное скрытие
	if not is_mouse_inside and not Global.is_dialogue_active:
		# Дадим тексту погореть 3 секунды после сообщения, а потом плавно скроем
		await get_tree().create_timer(3.0).timeout
		fade_out_chat()

# ПОКАЗ ЧАТА ПРИ НАВЕДЕНИИ
# МЫШКА ЗАШЛА НА ПАНЕЛЬ (Сигнал из редактора)
func _on_panel_mouse_entered() -> void:
	is_mouse_inside = true
	show_chat_instantly() # Мгновенно прерывает скрытие и зажигает чат!

# МЫШКА УШЛА С ПАНЕЛИ (Сигнал из редактора)
func _on_panel_mouse_exited() -> void:
	is_mouse_inside = false
	# Без всяких задержек СРАЗУ НАЧИНАЕТ растворяться!
	fade_out_chat()
	
# Мгновенно проявляет чат на 100% и убивает старый твин
func show_chat_instantly() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill() # Намертво останавливаем растворение в эту же миллисекунду!
	panel.modulate.a = 1.0
	
# Перезапускает таймер тишины чата
func reset_fade_timer() -> void:
	show_chat_instantly()
	
	# Запускаем чистый таймер на 4 секунды
	await get_tree().create_timer(4.0).timeout
	
	# Проверяем условия перед скрытием
	if not is_mouse_inside and not Global.is_dialogue_active:
		fade_out_chat()


# Плавно скрывает чат
func fade_out_chat() -> void:
	# Железная проверка: если мышка вернулась или идет диалог — никакого скрытия!
	if is_mouse_inside or Global.is_dialogue_active:
		return
		
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	fade_tween = create_tween()
	# Настраиваем скорость растворения. 
	# Число 1.0 — это время в секундах, за которое чат станет невидимым. 
	# Можешь поставить 0.5 (быстрее) или 2.0 (плавнее).
	fade_tween.tween_property(panel, "modulate:a", 0.0, 1.0)
