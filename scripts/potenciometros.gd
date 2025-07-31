extends Node

@onready var pot_rotacao = $potenciometro_rotacao
@onready var pot_voltagem1 = $pot_voltagem1
@onready var pot_voltagem2 = $pot_voltagem2
@onready var pot_corrente1 = $pot_corrente1
@onready var pot_corrente2 = $pot_corrente2

@onready var pots = [pot_voltagem1, pot_voltagem2, pot_corrente1, pot_corrente2]

var selecionado: potenciometro_click

func _ready() -> void:
	var rot_inicial = pot_rotacao.ANGULO_MIN
	pot_rotacao.visible = false
	
	for pot in pots:
		pot.rotation = rot_inicial

func _on_pot_voltagem_1_pressed() -> void:
	selecionar(pot_voltagem1)

func _on_pot_voltagem_2_pressed() -> void:
	selecionar(pot_voltagem2)

func _on_pot_corrente_1_pressed() -> void:
	selecionar(pot_corrente1)

func _on_pot_corrente_2_pressed() -> void:
	selecionar(pot_corrente2)

func selecionar(pot: potenciometro_click) -> void:
	if selecionado != pot:
		selecionado = pot
		pot_rotacao.rotation = selecionado.rotation
	else:
		selecionado = null
	
	pot_rotacao.visible = selecionado != null

func _on_potenciometro_rotacao_rotacionado(rotacao: float) -> void:
	if !selecionado: return
	var valor_saida_max = selecionado.VALOR_MAXIMO
	var rot_max = pot_rotacao.ANGULO_MAX
	var rot_min = pot_rotacao.ANGULO_MIN
	var saida = remap(rotacao, rot_min, rot_max, 0, valor_saida_max)
	saida = clamp(saida, 0, valor_saida_max)
	
	selecionado.rotation = rotacao
	selecionado.saida = saida
	print(floor(saida*100)/100)
