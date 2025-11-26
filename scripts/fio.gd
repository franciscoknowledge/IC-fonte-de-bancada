extends Line2D
class_name linha_fio
signal fio_clicado(saidas: Array)

const ALTURA_HITBOX = 12
const LARGURA_HITBOX = 12
const SIZE = 19

@export var saidas = []
@export var textura_armazenada: Resource = preload("res://imagens/fio_1.png")
@export var desabilitar = false
@export var tamanho = SIZE

func _ready() -> void:
	$hitbox_horizontal.input_event.connect(hitbox_clicada)
	$hitbox_vertical_1.input_event.connect(hitbox_clicada)
	$hitbox_vertical_2.input_event.connect(hitbox_clicada)

func redimensionar_hitbox_horizontal(collision_shape: CollisionShape2D, ponto_1: Vector2, ponto_2: Vector2) -> void:
	var w = abs(ponto_1.x - ponto_2.x) * 1.2
	var pos_x = (ponto_1.x + ponto_2.x) / 2
	
	var shape = collision_shape.shape
	
	collision_shape.position = Vector2(pos_x, ponto_1.y)
	shape.extents = Vector2(w / 2, ALTURA_HITBOX)
	
func redimensionar_hitbox_vertical(collision_shape: CollisionShape2D, ponto_1: Vector2, ponto_2: Vector2) -> void:
	var h = abs(ponto_1.y - ponto_2.y)
	var pos_y = (ponto_1.y + ponto_2.y) / 2
	
	var shape = collision_shape.shape
	
	collision_shape.position = Vector2(ponto_1.x, pos_y)
	shape.extents = Vector2(LARGURA_HITBOX, h)

# tem q ter a hitbox entre 1 e 2
func redimensionar_hitboxes() -> void:
	if points.size() < 4:
		print("o fio não possui a quantidade de pontos necessarios (%d/4)" % points.size())
		return
		
	#var area_2d_horizontal = $hitbox_horizontal
	var shape_horizontal = $hitbox_horizontal/shape_2d
	
	#var area_2d_vertical_1 = $hitbox_vertical_1
	var shape_vertical_1 = $hitbox_vertical_1/shape_2d
	
	#var area_2d_vertical_2 = $hitbox_vertical_2
	var shape_vertical_2 = $hitbox_vertical_2/shape_2d
	
	var ponto_1 = points[0]
	var ponto_2 = points[1]
	var ponto_3 = points[2]
	var ponto_4 = points[3]
	
	redimensionar_hitbox_horizontal(shape_horizontal, ponto_2, ponto_3)
	redimensionar_hitbox_vertical(shape_vertical_1, ponto_1, ponto_2)
	redimensionar_hitbox_vertical(shape_vertical_2, ponto_3, ponto_4)
	
	#var ponto_1 = points[1]
	#var ponto_2 = points[2]
	#
	#var w = abs(ponto_1.x - ponto_2.x) * 1.2
	#var pos_x = (ponto_1.x + ponto_2.x) / 2
	#
	#var collision_shape = $hitbox/shape_2d
	#var shape = collision_shape.shape
	#
	#collision_shape.position = Vector2(pos_x, ponto_1.y)
	#shape.extents = Vector2(w / 2, ALTURA_HITBOX)

func armazenar_textura(nova_textura: Resource) -> void:
	textura_armazenada = nova_textura
	texture = nova_textura
	
func usar_textura_armazenada() -> void:
	texture = textura_armazenada

func hitbox_clicada(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if desabilitar: return
	
	if !(event is InputEventMouseButton):
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		fio_clicado.emit(self, saidas)
