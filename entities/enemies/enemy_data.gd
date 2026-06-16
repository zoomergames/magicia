extends Resource
class_name EnemyData

@export var enemy_name: String = "Монстр"
@export var max_hp: int = 50
@export var speed: float = 50.0
@export var level: int = 1
@export var loot_table: Array[String] = [] # Список ID предметов для дропа
@export var has_artifact: bool = false
