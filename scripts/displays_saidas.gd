extends Node

@onready var hitboxes = $"../hitboxes"
@onready var potenciometros = $"../potenciometros"
@onready var pot_voltagem1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem2 = $"../potenciometros/pot_voltagem2"
@onready var seletora = $"../chave_seletora"

const PONTO_A = enums.SAIDAS.POS_2
const PONTO_B = enums.SAIDAS.POS_1
const PONTO_C = enums.SAIDAS.NEG_1
const PONTO_D = enums.SAIDAS.NEG_2

func get_primeiro_comum() -> int:
	var comuns = hitboxes.get_comuns()
	if comuns.size() <= 0:
		return -1
	
	return comuns[0]

#func modo_serie() -> void:
#	var v1 = pot_voltagem2.saida
#	var v2 = pot_voltagem2.saida
#	var ponto_comum = get_primeiro_comum()
#	if ponto_comum == -1:
#		ponto_comum = PONTO_C
#	
#	var potenciais = {
#		PONTO_A: v1 + v2,
#		PONTO_B: v1,
#		PONTO_C: 0,
#		PONTO_D: v1,
#	}
#	
#	var tensao_comum = potenciais[ponto_comum]
#	var va = potenciais[PONTO_A] - tensao_comum
#	var vb = potenciais[PONTO_B] - tensao_comum
#	var vc = potenciais[PONTO_C] - tensao_comum
#	var vd = potenciais[PONTO_D] - tensao_comum
#	
#	$d1.text = str(vb)
#	$d3.text = str(vc)
#	$d4.text = str(va)
#	$d6.text = str(vd)
#
#func modo_paralelo() -> void:
#	var v1 = pot_voltagem2.saida
#	var v2 = pot_voltagem2.saida
#	var ponto_comum = get_primeiro_comum()
#	if ponto_comum == -1:
#		ponto_comum = PONTO_C
#	
#	var potenciais = {
#		PONTO_A: v2,
#		PONTO_B: v1,
#		PONTO_C: 0,
#		PONTO_D: 0,
#	}
#	
#	var tensao_comum = potenciais[ponto_comum]
#	var va = potenciais[PONTO_A] - tensao_comum
#	var vb = potenciais[PONTO_B] - tensao_comum
#	var vc = potenciais[PONTO_C] - tensao_comum
#	var vd = potenciais[PONTO_D] - tensao_comum
#	
#	$d1.text = str(vb)
#	$d3.text = str(vc)
#	$d4.text = str(va)
#	$d6.text = str(vd)

func modo_serie_paralelo() -> void:
	var v1 = pot_voltagem2.saida
	var v2 = pot_voltagem2.saida
	var ponto_comum = get_primeiro_comum()
	if ponto_comum == -1:
		ponto_comum = PONTO_C
	
	var potenciais_serie = {
		PONTO_A: v1 + v2,
		PONTO_B: v1,
		PONTO_C: 0,
		PONTO_D: v1,
	}
	
	var potenciais_paralelo = {
		PONTO_A: v2,
		PONTO_B: v1,
		PONTO_C: 0,
		PONTO_D: 0,
	}
	
	var potenciais
	if seletora.estado == enums.ESTADOS_FONTE.SERIES:
		potenciais = potenciais_serie
	else:
		potenciais = potenciais_paralelo
	
	var tensao_comum = potenciais[ponto_comum]
	var va = potenciais[PONTO_A] - tensao_comum
	var vb = potenciais[PONTO_B] - tensao_comum
	var vc = potenciais[PONTO_C] - tensao_comum
	var vd = potenciais[PONTO_D] - tensao_comum
	
	$d1.text = str(vb)
	$d3.text = str(vc)
	$d4.text = str(va)
	$d6.text = str(vd)

func _process(f) -> void:
	if seletora.estado == enums.ESTADOS_FONTE.INDEP:
		$d1.text = "?"
		$d3.text = "?"
		$d4.text = "?"
		$d6.text = "?"
		return
	
	modo_serie_paralelo()
