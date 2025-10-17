extends Node
const VALOR_REFERENCIA_ZERO = 0.5

@onready var pot_rotacao = $potenciometro_rotacao
@onready var sprite_selecao = $sprite_selecao
@onready var pot_voltagem1 = $pot_voltagem1
@onready var pot_voltagem2 = $pot_voltagem2
@onready var pot_corrente1 = $pot_corrente1
@onready var pot_corrente2 = $pot_corrente2
@onready var hitboxes = $"../hitboxes"

@onready var pots = [pot_voltagem1, pot_voltagem2, pot_corrente1, pot_corrente2]

var selecionado: potenciometro_click

func _ready() -> void:
	var rot_inicial = pot_rotacao.ANGULO_MIN
	pot_rotacao.visible = false
	
	for pot: potenciometro_click in pots:
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
		sprite_selecao.position = selecionado.position + selecionado.pivot_offset
	else:
		selecionado = null
		
	var visivel = selecionado != null
	
	sprite_selecao.visible = visivel
	pot_rotacao.visible = visivel
	
func definir_saida(potenciometro: potenciometro_click, rotacao: float) -> void:
	var valor_saida_max = potenciometro.VALOR_MAXIMO
	
	var rot_max = pot_rotacao.ANGULO_MAX
	var rot_min = pot_rotacao.ANGULO_MIN
	
	var saida = remap(rotacao, rot_min, rot_max, 0, valor_saida_max)
	if potenciometro == pot_corrente1 and pot_voltagem1.saida < VALOR_REFERENCIA_ZERO:
		saida = 0
		
	if potenciometro == pot_corrente2 and pot_voltagem2.saida < VALOR_REFERENCIA_ZERO:
		saida = 0
	
	saida = clamp(saida, 0, valor_saida_max)
	saida = floor(saida * 100) / 100
	
	potenciometro.rotation = rotacao
	potenciometro.saida = saida
	potenciometro.saida_alterada.emit(saida)

func _on_potenciometro_rotacao_rotacionado(rotacao: float) -> void:
	if !selecionado: return
	for pot: potenciometro_click in pots:
		definir_saida(pot, pot.rotation)
		
	definir_saida(selecionado, rotacao)
	#if !selecionado: return
	#
	#if (selecionado == pot_corrente1) and (pot_voltagem1.saida == 0):
	#	return
	#	
	#if (selecionado == pot_corrente2) and (pot_voltagem2.saida == 0):
	#	return
	#
	#var valor_saida_max = selecionado.VALOR_MAXIMO
	#
	#var rot_max = pot_rotacao.ANGULO_MAX
	#var rot_min = pot_rotacao.ANGULO_MIN
	#
	#var saida = remap(rotacao, rot_min, rot_max, 0, valor_saida_max)
	#
	#saida = clamp(saida, 0, valor_saida_max)
	#saida = floor(saida * 100)/100
	#
	#selecionado.rotation = rotacao
	#selecionado.saida = saida
	#selecionado.saida_alterada.emit(saida)
