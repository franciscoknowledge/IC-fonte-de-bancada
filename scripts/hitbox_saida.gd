extends TextureButton
class_name HitboxSaida

@export var saida: enums.SAIDAS = enums.SAIDAS.POS_1
signal emitir_saida(saida: enums.SAIDAS, hitbox: HitboxSaida)

func _on_pressed() -> void:
	emitir_saida.emit(saida, self)
