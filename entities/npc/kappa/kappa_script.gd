extends RefCounted

var kappa_node: Node2D = null
var dialogue_step: int = 0
var was_met: bool = false

func start() -> void:
	dialogue()

func handle_input(event: InputEvent) -> void:
		if Global.name_input_node and Global.name_input_node.visible:
			return
		dialogue()

func dialogue() -> void:
	dialogue_step += 1
	
	# Получаем красивый зеленый префикс имени Каппы
	var hex_color = kappa_node.color_name.to_html(false)
	var prefix = "[color=#%s][%s][/color]" % [hex_color, kappa_node.npc_name]
	
	if not was_met:
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
			Global.log_to_chat("[color=gray]Вы получили [color=white]Маленький Меч[/color] за [color=yellow]0 золотых[/color]![/color]")
			# Финал: закрываем диалог
			was_met = true
			end_dialogue()
	else:
			Global.log_to_chat("%s [b][color=white]Я уже отдал тебе всё, что было! Иди тестируй эту зубочистку на гоблинах![/color][/b]" % prefix)
			end_dialogue()

func end_dialogue() -> void:
	dialogue_step = 0
	Global.end_dialogue() # Разморозит игрока в синглтоне
