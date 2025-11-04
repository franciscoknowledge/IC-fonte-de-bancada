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

var grafo = {}
var V_indep = {}

func get_primeiro_comum() -> int:
	var comuns = hitboxes.get_comuns()
	if comuns.size() <= 0:
		return -1
	
	return comuns[0]

func criar_permutacao(fio) -> Array:
	var permutacao = []
	permutacao.append(fio[1])
	permutacao.append(fio[0])
	return permutacao
	
func recebe_tensao_origem_destino(origem, destino):
	for key in grafo:
		if key == [origem, destino]:
			return grafo[key]
			
	print("Não achei a aresta (%s, %s) no grafo." % [origem, destino])
			
func recebe_vizinhos(no):
	var vizinhos = []
	for key in grafo:
		if key[0] == no:
			vizinhos.append(key[1])
			
	if vizinhos.is_empty():
		print("O nó %s não tem vizinhos" % no)
	return vizinhos
	
func percorre(atual, origem):
	if origem:
		V_indep[atual] = V_indep[origem] + recebe_tensao_origem_destino(origem, atual)
		
	var vizinhos = recebe_vizinhos(atual)
	if origem in vizinhos:
		vizinhos.erase(origem)
		
	for vizinho in vizinhos:
		percorre(vizinho, atual)

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

func modo_indep() -> void:
	var v1 = pot_voltagem1.saida
	var v2 = pot_voltagem2.saida
	
	grafo = {
		[PONTO_C, PONTO_A]: v1,
		[PONTO_D, PONTO_B]: v2,
		[PONTO_A, PONTO_C]: -v1,
		[PONTO_B, PONTO_D]: -v2,
	}
	
	for fio in hitboxes.fios_na_fonte:
		grafo[fio] = 0
		grafo[criar_permutacao(fio)] = 0
	
	V_indep = {
		PONTO_A: 0,
		PONTO_B: 0,
		PONTO_C: 0,
		PONTO_D: 0,
	}
	
	var comuns = hitboxes.get_comuns()
	for comum in comuns:
		percorre(comum, null)
	
	$d1.text = str(V_indep[PONTO_B])
	$d3.text = str(V_indep[PONTO_C])
	$d4.text = str(V_indep[PONTO_A])
	$d6.text = str(V_indep[PONTO_D])

# melhorar depois pfv
# usa um match ai pls
func _process(_delta) -> void:
	match seletora.estado:
		enums.ESTADOS_FONTE.INDEP:
			modo_indep()
		enums.ESTADOS_FONTE.SERIES:
			modo_serie_paralelo()
		enums.ESTADOS_FONTE.PARALELL:
			modo_serie_paralelo()
	
	if $"../botao_on_off".button_pressed:
		$d1.visible = true
		$d3.visible = true
		$d4.visible = true
		$d6.visible = true
	else:
		$d1.visible = false
		$d3.visible = false
		$d4.visible = false
		$d6.visible = false
