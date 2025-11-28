extends TextureButton
class_name PotenciometroClick

signal saida_alterada(saida: float)

# pq 21???
@export var VALOR_MAXIMO: float = 21
@export var saida: float = 0

#func _process(_delta: float) -> void:
#	$Label.text = str(saida)

# so quero silenciar o erro pelo amor de deus
func set_saida(novo_valor: float) -> void:
	saida = novo_valor
	saida_alterada.emit(saida)
