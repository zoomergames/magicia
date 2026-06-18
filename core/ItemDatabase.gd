extends Node

var registry: Dictionary = {
	"001": {
		"type": "weapon",
		"data_script": "res://items/weapons/little_sword/little_sword.tres"
	},
	"002": {
		"type": "armor",
		"data_script": "res://items/armors/super_costume/super_costume.tres"
	},
	"003": {
		"type": "amulet",
		"data_script": "res://items/artifacts/magisyanik_hand/magisyanik_hand.tres"
		},
	"004": {
		"tyoe": "weapon",
		"data_script": "res://items/weapons/fist/fist.tres"
	},
	"005": {
		"type": "weapon",
		"data_script": "res://items/weapons/ak-47/ak-47.tres"
	},
	"006": {
		"type": "weapon",
		"data_script": "res://items/weapons/dragon_slayer/dragon_slayer.tres"
	}
}

func get_item_tooltip_text(item_data: Resource) -> String:
	if item_data == null:
		return ""
	
	var item_name = item_data.item_name
	if item_name == null or item_name == "":
		item_name = "Неизвестно"

	var name_text = "[b][color=white]%s[/color][/b]" % item_name
	var desc_text = "[color=gray]%s[/color]" % item_data.description

	var stats_text = ""
	# ПРОВЕРЯЕМ, ЕСТЬ ЛИ ПОЛЕ, А НЕ ПРОСТО ЧИТАЕМ ЕГО!
	if "damage" in item_data and item_data.damage != null:
		stats_text = "\n\n[color=red]Урон: %d[/color]\n[color=lightblue]Скорость: %s сек.[/color]" % [item_data.damage, item_data.attack_speed]
	elif "defense" in item_data and item_data.defense != null:
		stats_text = "\n\n[color=green]Защита: +%d[/color]" % item_data.defense
	elif "mana_bonus" in item_data and item_data.mana_bonus != null:
		stats_text = "\n\n[color=purple]Мана: +%d[/color]" % item_data.mana_bonus
		
	if "confidence" in item_data and item_data.confidence != null:
		stats_text += "\n[color=white]Уверенность: +%d[/color]" % item_data.confidence
	
	if "weirdness" in item_data and item_data.weirdness != null:
		stats_text += "\n[color=purple]Странность: +%d[/color]" % item_data.weirdness
		
	return name_text + "\n\n" + desc_text + stats_text
