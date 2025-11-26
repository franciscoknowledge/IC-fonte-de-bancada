extends Node
const VALOR_REFERENCIA_ZERO = 0.2

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
	#var corrente_1_em_zero = (pot_corrente1.saida < VALOR_REFERENCIA_ZERO)
	#var corrente_2_em_zero = (pot_corrente2.saida < VALOR_REFERENCIA_ZERO)
	#
	#var tensao_1_em_zero = (pot_voltagem1.saida < VALOR_REFERENCIA_ZERO)
	#var tensao_2_em_zero = (pot_voltagem2.saida < VALOR_REFERENCIA_ZERO)
	#
	#if potenciometro == pot_voltagem1 or potenciometro == pot_corrente1:
	#	if tensao_1_em_zero or corrente_1_em_zero:
	#		saida = 0
	#		
	#if potenciometro == pot_voltagem2 or potenciometro == pot_corrente2:
	#	if tensao_2_em_zero or corrente_2_em_zero:
	#		saida = 0
	if potenciometro == pot_corrente1 and pot_voltagem1.saida < VALOR_REFERENCIA_ZERO:
		saida = 0
		
	if potenciometro == pot_corrente2 and pot_voltagem2.saida < VALOR_REFERENCIA_ZERO:
		saida = 0
	
	saida = clamp(saida, 0, valor_saida_max)
	saida = floor(saida * 100) / 100
	
	potenciometro.rotation = rotacao
	potenciometro.saida = saida
	potenciometro.saida_alterada.emit(saida)
	
func get_potenciometro_em_zero(potenciometro: potenciometro_click) -> bool:
	return (potenciometro.saida < VALOR_REFERENCIA_ZERO)

func get_fonte_zerada(fonte: enums.FONTES) -> bool:
	var potenciometros = []
	if (fonte == enums.FONTES.FONTE_1):
		potenciometros = [pot_voltagem1, pot_corrente1]
	elif (fonte == enums.FONTES.FONTE_2):
		potenciometros = [pot_voltagem2, pot_corrente2]
	
	var zerada = (get_potenciometro_em_zero(potenciometros[0]) or get_potenciometro_em_zero(potenciometros[1]))
	return zerada
