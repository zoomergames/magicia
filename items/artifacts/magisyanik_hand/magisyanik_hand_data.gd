extends Resource

var item_name: String = "Ладонь Маджисяника"
var item_id: String = "003"
var description: String = "Странная летающая рука с глазом. Даёт жуткую уверенность."
@export var icon: Texture2D
@export var scene: PackedScene
var mana_bonus: int = 20
var confidence: int = 10   # +10 к уверенности
var weirdness: int = 10    # +10 к странности
