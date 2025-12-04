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

@onready var pares_pot = {
	pot_voltagem1: pot_corrente1,
	pot_voltagem2: pot_corrente2,
	
	pot_corrente1: pot_voltagem1,
	pot_corrente2: pot_voltagem2,
}

var selecionado: PotenciometroClick

func _ready() -> void:
	var rot_inicial = pot_rotacao.ANGULO_MIN
	pot_rotacao.visible = false
	
	for pot: PotenciometroClick in pots:
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
	selecionado.rotation = rotacao
	
	for pot: PotenciometroClick in pots:
		definir_saida(pot)
	
func checar_zero(pot: PotenciometroClick) -> bool:
	return (pot.saida < VALOR_REFERENCIA_ZERO)

func selecionar(pot: PotenciometroClick) -> void:
	if selecionado != pot:
		selecionado = pot
		pot_rotacao.rotation = selecionado.rotation
		sprite_selecao.position = selecionado.position + selecionado.pivot_offset
	else:
		selecionado = null
		
	var visivel = selecionado != null
	
	sprite_selecao.visible = visivel
	pot_rotacao.visible = visivel

func get_saida(potenciometro: PotenciometroClick) -> float:
	var valor_saida_max = potenciometro.VALOR_MAXIMO
	
	var rot_max = pot_rotacao.ANGULO_MAX
	var rot_min = pot_rotacao.ANGULO_MIN
	
	var saida = remap(potenciometro.rotation, rot_min, rot_max, 0, valor_saida_max)
	saida = clamp(saida, 0, valor_saida_max)
	saida = floor(saida * 100) / 100
	
	return saida

func definir_saida(potenciometro: PotenciometroClick) -> void:
	var par = pares_pot[potenciometro]
	
	var saida = get_saida(potenciometro)
	var saida_par = get_saida(par)
	
	if saida < VALOR_REFERENCIA_ZERO or saida_par < VALOR_REFERENCIA_ZERO:
		saida = 0
		
	potenciometro.set_saida(saida)

func get_potenciometro_em_zero(potenciometro: PotenciometroClick) -> bool:
	return (potenciometro.saida < VALOR_REFERENCIA_ZERO)
	
func get_potenciometro_em_zero_rotacao(potenciometro: PotenciometroClick) -> bool:
	return (get_saida(potenciometro) < VALOR_REFERENCIA_ZERO)

func get_fonte_zerada(fonte: EnumsGlobal.FONTES) -> bool:
	var potenciometros = []
	if (fonte == EnumsGlobal.FONTES.FONTE_1):
		potenciometros = [pot_voltagem1, pot_corrente1]
	elif (fonte == EnumsGlobal.FONTES.FONTE_2):
		potenciometros = [pot_voltagem2, pot_corrente2]
	
	var zerada = (get_potenciometro_em_zero(potenciometros[0]) or get_potenciometro_em_zero(potenciometros[1]))
	return zerada
