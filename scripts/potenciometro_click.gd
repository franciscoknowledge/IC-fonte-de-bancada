extends TextureButton
class_name PotenciometroClick

signal saida_alterada(saida: float)

# pq 21???
@export var VALOR_MAXIMO: float = 21
@export var saida: float = 0
