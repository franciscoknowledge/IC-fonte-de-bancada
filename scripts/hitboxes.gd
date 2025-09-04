extends Node

@onready var hitboxes = get_children()
@onready var popup = $"../popupComum"
func test(saida, hitbox: hitbox_saida):
	popup.position = hitbox.position
	popup.visible = true

func _ready() -> void:
	for hitbox: hitbox_saida in hitboxes:
		if not (hitbox is hitbox_saida):
			continue
		hitbox.emitir_saida.connect(test)
