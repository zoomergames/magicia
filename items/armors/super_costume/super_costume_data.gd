extends Resource

var item_name: String = "Супер Костюм"
var item_id: String = "002"
var description: String = "Выглядит мощно, но защиты ноль. Зато стильно!"
@export var icon: Texture2D
@export var scene: PackedScene
var defense: int = 0
var confidence: int = 10  # +10 к уверенности
