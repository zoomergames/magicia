extends DialogueManager

# Больше никаких if not was_met! Этот файл знает только про ПЕРВУЮ встречу.
# Переопределяем функцию шага, которую вызывает наш DialogueManager
func run_dialogue_step() -> void:
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
	elif dialogue_step == 4:
		end_dialogue()

func _on_name_submitted(new_text: String) -> void:
	if new_text.strip_edges() != "":
		Global.player_name = new_text
	Global.name_input_node.visible = false
	Global.name_input_node.text_submitted.disconnect(_on_name_submitted)
	
	# Толкаем базовый менеджер к Шагу 3 (используем имя из DialogueManager)
	advance_dialogue() 
