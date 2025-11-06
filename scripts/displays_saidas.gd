extends Node

@onready var hitboxes = $"../hitboxes"
@onready var potenciometros = $"../potenciometros"
@onready var pot_voltagem1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem2 = $"../potenciometros/pot_voltagem2"
@onready var seletora = $"../chave_seletora"
@onready var botao = $"../botao_on_off"

const SP_PONTO_A = enums.SAIDAS.POS_2
const SP_PONTO_B = enums.SAIDAS.POS_1
const SP_PONTO_C = enums.SAIDAS.NEG_1
const SP_PONTO_D = enums.SAIDAS.NEG_2

const INDEP_PONTO_A = enums.SAIDAS.POS_1
const INDEP_PONTO_B = enums.SAIDAS.POS_2
const INDEP_PONTO_C = enums.SAIDAS.NEG_1
const INDEP_PONTO_D = enums.SAIDAS.NEG_2

@onready var labels = [$d1, $d3, $d4, $d6]

var grafo = {}
var V_indep = {}
var visitados = []
var ciclo_detectado = false

func toggle_visibilidade_labels(visivel) -> void:
	for label in labels:
		label.visible = visivel

func escrever_labels(d1, d2, d3, d4) -> void:
	var valores = [d1, d2, d3, d4]
	
	for i in range(labels.size()):
		var label = labels[i]
		var valor = valores[i]
		var str = str(valor)
		
		label.text = str
	
func get_primeiro_comum() -> int:
	var comuns = hitboxes.get_comuns()
	if comuns.size() <= 0:
		return -1
	
	return comuns[0]

func indep_criar_permutacao(fio) -> Array:
	return [fio[1], fio[0]]
	
func indep_recebe_tensao_origem_destino(origem, destino) -> Variant:
	for key in grafo:
		if key == [origem, destino]:
			return grafo[key]
			
	print("Não achei a aresta (%s, %s) no grafo." % [origem, destino])
	return null
			
func indep_recebe_vizinhos(no) -> Array:
	var vizinhos = []
	for key in grafo:
		if key[0] == no:
			vizinhos.append(key[1])
			
	if vizinhos.is_empty():
		print("O nó %s não tem vizinhos" % no)
	return vizinhos
	
func indep_percorre(atual, origem) -> void:
	if atual in visitados:
		print("ciclo no nó %s" % atual)
		ciclo_detectado = true
		return
		
	visitados.append(atual)
	
	if origem:
		V_indep[atual] = V_indep[origem] + indep_recebe_tensao_origem_destino(origem, atual)
		
	var vizinhos = indep_recebe_vizinhos(atual)
	if origem in vizinhos:
		vizinhos.erase(origem)
		
	for vizinho in vizinhos:
		indep_percorre(vizinho, atual)

func indep_construir_grafo_e_tensoes(v1, v2) -> void:
	grafo = {
		[INDEP_PONTO_C, INDEP_PONTO_A]: v1,
		[INDEP_PONTO_D, INDEP_PONTO_B]: v2,
		[INDEP_PONTO_A, INDEP_PONTO_C]: -v1,
		[INDEP_PONTO_B, INDEP_PONTO_D]: -v2,
	}
	
	for fio in hitboxes.fios_na_fonte:
		grafo[fio] = 0
		grafo[indep_criar_permutacao(fio)] = 0
	
func indep_limpar_variaveis() -> void:
	V_indep = {
		INDEP_PONTO_A: 0,
		INDEP_PONTO_B: 0,
		INDEP_PONTO_C: 0,
		INDEP_PONTO_D: 0,
	}
	
	visitados.clear()
	ciclo_detectado = false

func modo_serie_paralelo() -> void:
	var v1 = pot_voltagem2.saida
	var v2 = pot_voltagem2.saida
	var ponto_comum = get_primeiro_comum()
	if ponto_comum == -1:
		ponto_comum = SP_PONTO_C
	
	var potenciais_serie = {
		SP_PONTO_A: v1 + v2,
		SP_PONTO_B: v1,
		SP_PONTO_C: 0,
		SP_PONTO_D: v1,
	}
	
	var potenciais_paralelo = {
		SP_PONTO_A: v2,
		SP_PONTO_B: v1,
		SP_PONTO_C: 0,
		SP_PONTO_D: 0,
	}
	
	var potenciais
	if seletora.estado == enums.ESTADOS_FONTE.SERIES:
		potenciais = potenciais_serie
	else:
		potenciais = potenciais_paralelo
	
	var tensao_comum = potenciais[ponto_comum]
	var va = potenciais[SP_PONTO_A] - tensao_comum
	var vb = potenciais[SP_PONTO_B] - tensao_comum
	var vc = potenciais[SP_PONTO_C] - tensao_comum
	var vd = potenciais[SP_PONTO_D] - tensao_comum
	
	escrever_labels(vb, vc, va, vd)
	
	#$d1.text = str(vb)
	#$d3.text = str(vc)
	#$d4.text = str(va)
	#$d6.text = str(vd)

func modo_indep() -> void:
	var v1 = pot_voltagem1.saida
	var v2 = pot_voltagem2.saida
	
	indep_construir_grafo_e_tensoes(v1, v2)
	indep_limpar_variaveis()
	
	var comuns = hitboxes.get_comuns()
	
	for comum in comuns:
		indep_percorre(comum, null)
		
	if ciclo_detectado:
		for label in labels:
			label.text = "!"
		return
	
	#$d1.text = str(V_indep[PONTO_A])
	#$d3.text = str(V_indep[PONTO_C])
	#$d4.text = str(V_indep[PONTO_B])
	#$d6.text = str(V_indep[PONTO_D])
	
	escrever_labels(V_indep[INDEP_PONTO_A], V_indep[INDEP_PONTO_C], V_indep[INDEP_PONTO_B], V_indep[INDEP_PONTO_D])
	
func calcular_potenciais() -> void:
	if !(botao.button_pressed):
		return
	
	if (seletora.estado == enums.ESTADOS_FONTE.INDEP):
		modo_indep()
	else:
		modo_serie_paralelo()

func _on_botao_on_off_toggled(toggled_on: bool) -> void:
	toggle_visibilidade_labels(toggled_on)
	calcular_potenciais()

func _on_pot_voltagem_1_saida_alterada(_saida: Variant) -> void:
	calcular_potenciais()

func _on_pot_voltagem_2_saida_alterada(_saida: Variant) -> void:
	calcular_potenciais()

func _on_hitboxes_fonte_modificada() -> void:
	calcular_potenciais()
