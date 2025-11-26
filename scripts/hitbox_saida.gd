extends TextureButton
class_name hitbox_saida

@export var saida: enums.SAIDAS
signal emitir_saida(saida: enums.SAIDAS, hitbox: hitbox_saida)

func _on_pressed() -> void:
	emitir_saida.emit(saida, self)
