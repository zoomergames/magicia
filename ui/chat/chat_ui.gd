extends CanvasLayer

var regex = RegEx.new()
var old_text: String = ""

func _ready() -> void:
	Global.chat_node = $Panel/RichTextLabel
	Global.name_input_node = $NameInput
	
	# Компилируем шаблон: разрешены a-z, A-Z, 0-9, а-я, А-Я, ё, Ё
	regex.compile("^[a-zA-Z0-9а-яА-ЯёЁ]*$")
	
	# Подключаем сигнал: каждый раз, когда текст меняется, вызываем нашу проверку
	$NameInput.text_changed.connect(_on_name_text_changed)
	
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
