extends DialogueManager

func run_dialogue_step() -> void:
	if dialogue_step == 1:
		Global.log_to_chat("%s [b][color=white]Я уже отдал тебе всё, что было! Иди тестируй эту зубочистку на гоблинах![/color][/b]" % prefix)
	elif dialogue_step == 2:
		Global.log_to_chat("[b][color=gray][Система] Нажмите Enter для завершения диалога [/color][/b]")
	elif dialogue_step == 3:
		end_dialogue()
