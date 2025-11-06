extends Line2D
class_name linha_fio
signal fio_clicado(saidas)

const ALTURA_HITBOX = 12
@export var saidas = []
@export var textura_armazenada: Resource = preload("res://imagens/fio_1.png")

# tem q ter a hitbox entre 1 e 2
func redimensionar_hitbox() -> void:
	if points.size() < 4:
		print("o fio não possui a quantidade de pontos necessarios (%d/4)" % points.size())
		return
	
	var ponto_1 = points[1]
	var ponto_2 = points[2]
	
	var w = abs(ponto_1.x - ponto_2.x) * 1.2
	var pos_x = (ponto_1.x + ponto_2.x) / 2
	
	var collision_shape = $hitbox/shape_2d
	var shape = collision_shape.shape
	
	collision_shape.position = Vector2(pos_x, ponto_1.y)
	shape.extents = Vector2(w / 2, ALTURA_HITBOX)

func armazenar_textura(nova_textura: Resource) -> void:
	textura_armazenada = nova_textura
	texture = nova_textura
	
func usar_textura_armazenada() -> void:
	texture = textura_armazenada

func _on_hitbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if !(event is InputEventMouseButton):
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		fio_clicado.emit(self, saidas)
