extends DialogueManager

func run_dialogue_step() -> void:
	if dialogue_step == 1:
		Global.log_to_chat("[color=gray]На Вас пристально пялится Каппа[/color]")
	elif dialogue_step == 2:
		Global.log_to_chat("%s [b][color=white]О! Здарова, [i][color=orange]%s[/color][/i]![/color][/b]" % [prefix, Global.player_name])	
	elif dialogue_step == 3:
		Global.log_to_chat("%s [b][color=white]Я вижу, что ты явно хочешь у меня что-то купить. Не притворяйся![/color][/b]" % prefix)
	elif dialogue_step == 4:	
		Global.log_to_chat("[color=orange][%s][/color] [b][color=white]Ладно, чёрт возьми! Ты меня выкусил![/color][/b]" % Global.player_name)
	elif dialogue_step == 5:
		Global.log_to_chat("[color=orange][%s][/color] [b][color=white]Дай мне самый крутой меч, который у тебя есть.[/color][/b]" % Global.player_name)
	elif dialogue_step == 6:
		Global.log_to_chat("%s [b][color=white]Что же ты дашь взамен, о великий путник?[/color][/b]" % prefix)
	elif dialogue_step == 7:
		Global.log_to_chat("[color=orange][%s][/color] [b][color=white]Ну-у... ничего?[/color][/b]" % Global.player_name)
	elif dialogue_step == 8:
		var path = "res://entities/player/weapons/little_sword/little_sword.tres" # проверьте этот путь!
	
		if not ResourceLoader.exists(path):
			Global.log_to_chat("[color=red][Система]: Ошибка! Файл меча потерялся в текстурах Каппы.[/color]")
			end_dialogue()
			return
		
		var sword_data = load(path)

		var success: bool = Global.add_item_to_first_free_slot(sword_data)
		
		if success:
			Global.log_to_chat("[color=gray]Вы получили [b][color=white]%s[/color][/b] за [color=yellow]0 золотых[/color]![/color]" % sword_data.weapon_name)
			
			var inventory_ui: CanvasLayer = npc_node.get_tree().get_first_node_in_group("inventory_ui")
			if inventory_ui and inventory_ui.has_method("update_all_slots"):
				inventory_ui.update_all_slots()
			
			var player: CharacterBody2D = npc_node.get_tree().get_first_node_in_group("player")
			if player and player.has_method("change_hand_weapon"):
				player.change_hand_weapon()
		
		end_dialogue()
