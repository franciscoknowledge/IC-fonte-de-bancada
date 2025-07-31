extends Node

@onready var pot_rotacao = $potenciometro_rotacao
@onready var pot_voltagem1 = $pot_voltagem1
@onready var pot_voltagem2 = $pot_voltagem2
@onready var pot_corrente1 = $pot_corrente1
@onready var pot_corrente2 = $pot_corrente2

var selecionado

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rot_incial = pot_rotacao.ANGULO_MIN
	pot_rotacao.visible = false
	
	pot_voltagem1.rotation = rot_incial
	pot_voltagem2.rotation = rot_incial
	pot_corrente1.rotation = rot_incial
	pot_corrente2.rotation = rot_incial

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pot_voltagem_1_pressed() -> void:
	selecionar(pot_voltagem1)

func _on_pot_voltagem_2_pressed() -> void:
	selecionar(pot_voltagem2)

func _on_pot_corrente_1_pressed() -> void:
	selecionar(pot_corrente1)

func _on_pot_corrente_2_pressed() -> void:
	selecionar(pot_corrente2)

func selecionar(pot) -> void:
	if selecionado != pot:
		selecionado = pot
	else:
		selecionado = null
	
	pot_rotacao.visible = selecionado != null
	pot_rotacao.rotation = selecionado.rotation

func _on_potenciometro_rotacao_rotacionado(r) -> void:
	if !selecionado: return
	var valor_max_pot = selecionado.VALOR_MAXIMO
	var rot_max = pot_rotacao.ANGULO_MAX
	var rot_min = pot_rotacao.ANGULO_MIN
	var saida = remap(r, rot_min, rot_max, 0, valor_max_pot)
	saida = clamp(saida, 0, valor_max_pot)
	
	selecionado.rotation = r
	selecionado.saida = saida
