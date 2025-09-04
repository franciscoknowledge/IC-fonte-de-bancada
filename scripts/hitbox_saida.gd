extends TextureButton
class_name hitbox_saida

@export var saida: int
signal emitir_saida(saida, hitbox)

func _on_pressed() -> void:
	emitir_saida.emit(saida, self)
