extends RefCounted

var goddess_node: Node2D = null # Ссылка на богиню, заполнится автоматически
var dialogue_step: int = 0
var was_met: bool = false

func start() -> void:
	dialogue()
	
func handle_input(_event: InputEvent) -> void:
	# Если открыто поле ввода имени — жестко блокируем пролистывание
	if Global.name_input_node and Global.name_input_node.visible:
		return
	dialogue()

func dialogue() -> void:
	dialogue_step += 1
	
	# Получаем префикс имени из настроек Богини
	var hex_color = goddess_node.color_name.to_html(false)
	var prefix = "[color=#%s][%s][/color]" % [hex_color, goddess_node.npc_name]
	
	if not was_met:
		# ЛОГИКА ПЕРВОЙ ВСТРЕЧИ
		if dialogue_step == 1:
			Global.log_to_chat("%s [b][color=white]Приветствую Вас, Герой![/color][/b]" % prefix)
		elif dialogue_step == 2:
			Global.log_to_chat("%s [b][color=white]Как мне Вас величать?[/color][/b]" % prefix)
			if Global.name_input_node:
				Global.name_input_node.visible = true
				Global.name_input_node.grab_focus()
				if not Global.name_input_node.text_submitted.is_connected(_on_name_submitted):
					Global.name_input_node.text_submitted.connect(_on_name_submitted)
		elif dialogue_step == 3:
			Global.log_to_chat("%s [b][color=white]Да здравствует великий [i][color=orange]%s[/color][/i]![/color][/b]" % [prefix, Global.player_name])
			was_met = true
			end_dialogue()
	else:
		# ЛОГИКА ПОВТОРНОЙ ВСТРЕЧИ
			Global.log_to_chat("%s [b][color=white]А, это снова ты, [i][color=orange]%s[/color][/i]? Хватит в меня тыкать, иди спасай мир![/color][/b]" % [prefix, Global.player_name])
			end_dialogue()

# СЮДА уехала вся логика сохранения имени игрока
func _on_name_submitted(new_text: String) -> void:
	if new_text.strip_edges() != "":
		Global.player_name = new_text
	Global.name_input_node.visible = false
	Global.name_input_node.text_submitted.disconnect(_on_name_submitted)
	dialogue()

func end_dialogue() -> void:
	dialogue_step = 0
	
	Global.end_dialogue() # Размораживаем игрока в синглтоне
