extends TextureButton
class_name HitboxSaida

@export var saida: EnumsGlobal.SAIDAS = EnumsGlobal.SAIDAS.POS_1
signal emitir_saida(saida: EnumsGlobal.SAIDAS, hitbox: HitboxSaida)

func _on_pressed() -> void:
	emitir_saida.emit(saida, self)
