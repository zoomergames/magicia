extends DialogueManager

func run_dialogue_step() -> void:
	if dialogue_step == 1:
		Global.log_to_chat("%s [b][color=white]А, это снова ты, [i][color=orange]%s[/color][/i]? Хватит в меня тыкать, иди спасай мир![/color][/b]" % [prefix, Global.player_name])
	elif dialogue_step == 2:
		Global.log_to_chat("[b][color=gray][Система] Нажмите Enter для завершения диалога [/color][/b]")
	elif dialogue_step == 3:
		end_dialogue()
