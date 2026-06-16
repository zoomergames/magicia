extends EnemyBase

func _ready() -> void:
	super() # Сначала выполняем всё, что написано в базовом EnemyBase!
	sprite = %Sprite2D

func _on_hit_box_area_entered(area: Area2D) -> void:
	print("[ОТЛАДКА СЛАЙМА]: В мой хитбокс влетела зона с именем: ", area.name)
	
	# Ваша старая проверка
	if area.has_meta("attack_power"):
		print("[ОТЛАДКА СЛАЙМА]: Нашёл метаданные урона! Наношу.")
		take_damage(area.get_meta("attack_power"))
	else:
		print("[ОТЛАДКА СЛАЙМА]: Метаданных урона на этой зоне НЕТ.")
