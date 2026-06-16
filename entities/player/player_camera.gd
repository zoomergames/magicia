extends Camera2D

# Скорость сглаживания камеры (чем больше число, тем быстрее она летит за игроком)
@export var follow_speed: float = 5.0

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Мягко притягиваем текущую позицию камеры к позиции игрока.
		# Функция lerp сама высчитает идеальный шаг без субпиксельного дрожания!
		global_position = global_position.lerp(player.global_position, follow_speed * delta)
