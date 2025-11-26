extends Node

const COR_DISPLAY_F1 = Color("5b6585")
const COR_DISPLAY_F2 = Color("78568c")
const COR_DISPLAY_5V = Color("444be4")

const COR_DISPLAY_ERRO = Color("fccd00ff")

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

const INDEP_POS_5V = enums.SAIDAS.POS_5V
const INDEP_NEG_5V = enums.SAIDAS.NEG_5V

@onready var d1: Label = $d1
@onready var d3: Label = $d3
@onready var d4: Label = $d4
@onready var d6: Label = $d6

@onready var d7: Label = $d7
@onready var d8: Label = $d8

@onready var labels = [d1, d3, d4, d6, d7, d8]
@onready var labels_serie_paralelo = [d1, d3, d4, d6]

@onready var visitado_para_label: Dictionary[int, Label] = {
	INDEP_PONTO_A: d1,
	INDEP_PONTO_B: d4,
	INDEP_PONTO_C: d3,
	INDEP_PONTO_D: d6,
	
	INDEP_POS_5V: d7,
	INDEP_NEG_5V: d8,
}

var grafo = {}
var V_indep = {}
var visitados = []
var ciclo_detectado = false:
	set(valor):
		ciclo_detectado = valor
		colorir_labels()
		
func _ready() -> void:
	for label: Label in labels:
		label.set_meta("cor_inicial", label.get_theme_color("font_outline_color"))

func _on_fonte_update() -> void:
	calcular_potenciais()
	checar_fontes_em_zero()
	colorir_labels()

func _on_botao_on_off_toggled(toggled_on: bool) -> void:
	if toggled_on: return
	toggle_visibilidade_labels(toggled_on)

func colorir_labels() -> void:
	var cor = COR_DISPLAY_ERRO
	for label: Label in labels:
		if !ciclo_detectado:
			cor = label.get_meta("cor_inicial")
		#label.remove_theme_color_override("font_outline_color")
		label.add_theme_color_override("font_outline_color", cor)

func toggle_visibilidade_labels(visivel) -> void:
	for label in labels:
		label.visible = visivel

func escrever_labels(valores: Array) -> void:
	for i in range(min(labels.size(), valores.size())):
		var label: Label = labels[i]
		var valor = valores[i]
		label.text = "%.2f V" % valor
	
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
		[INDEP_NEG_5V, INDEP_POS_5V]: 5,
		[INDEP_POS_5V, INDEP_NEG_5V]: -5,
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
		INDEP_POS_5V: 0,
		INDEP_NEG_5V: 0,
	}
	
	visitados.clear()
	ciclo_detectado = false

func modo_serie_paralelo() -> void:
	ciclo_detectado = false
	
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
	
	var potenciais: Dictionary
	if seletora.estado == enums.ESTADOS_FONTE.SERIES:
		potenciais = potenciais_serie
	else:
		potenciais = potenciais_paralelo
		
	var tensao_comum = potenciais[ponto_comum]
	var va = potenciais[SP_PONTO_A] - tensao_comum
	var vb = potenciais[SP_PONTO_B] - tensao_comum
	var vc = potenciais[SP_PONTO_C] - tensao_comum
	var vd = potenciais[SP_PONTO_D] - tensao_comum
	
	for label in labels_serie_paralelo:
		label.visible = true
	
	labels[4].visible = false
	labels[5].visible = false
	
	escrever_labels([vb, vc, va, vd, 5, 0])
	
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
		
	for label in labels:
		label.visible = false

	for visitado in visitados:
		visitado_para_label[visitado].visible = true
		
	if ciclo_detectado:
		for label in labels:
			label.text = "!!!"
		return
	
	#$d1.text = str(V_indep[PONTO_A])
	#$d3.text = str(V_indep[PONTO_C])
	#$d4.text = str(V_indep[PONTO_B])
	#$d6.text = str(V_indep[PONTO_D])
	
	var va = V_indep[INDEP_PONTO_A]
	var vc = V_indep[INDEP_PONTO_C]
	var vb = V_indep[INDEP_PONTO_B]
	var vd = V_indep[INDEP_PONTO_D]
	
	var v_pos_5v = V_indep[INDEP_POS_5V]
	var v_neg_5v = V_indep[INDEP_NEG_5V]
	var valores = [vb, vc, va, vd, v_pos_5v, v_neg_5v]
	
	escrever_labels(valores)
	
func calcular_potenciais() -> void:
	if !(botao.button_pressed):
		return
	
	if (seletora.estado == enums.ESTADOS_FONTE.INDEP):
		modo_indep()
	else:
		modo_serie_paralelo()
		
func checar_fontes_em_zero() -> void:
	if ciclo_detectado: return
	
	if potenciometros.get_fonte_zerada(enums.FONTES.FONTE_1):
		labels[0].text = "%.2f V" % 0
		labels[1].text = "%.2f V" % 0
		
	if potenciometros.get_fonte_zerada(enums.FONTES.FONTE_2):
		labels[2].text = "%.2f V" % 0
		labels[3].text = "%.2f V" % 0
