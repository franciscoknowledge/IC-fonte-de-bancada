extends Node

const COR_ON = Color.RED
const COR_OFF = Color.TRANSPARENT

@onready var hitboxes = $"../hitboxes"

@onready var pot_voltagem1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem2 = $"../potenciometros/pot_voltagem2"
@onready var pot_corrente1 = $"../potenciometros/pot_corrente1"
@onready var pot_corrente2 = $"../potenciometros/pot_corrente2"

@onready var display_voltagem1 = $voltagem1
@onready var display_voltagem2 = $voltagem2
@onready var display_corrente1 = $corrente1
@onready var display_corrente2 = $corrente2

@onready var ch_seletora = $"../chave_seletora"

var tween: Tween

func _ready() -> void:
	display_voltagem1.modulate = COR_OFF
	display_voltagem2.modulate = COR_OFF
	display_corrente1.modulate = COR_OFF
	display_corrente2.modulate = COR_OFF
	
func _process(delta: float) -> void:
	#var fonte1_tem_voltagem = (pot_voltagem1.saida == 0)
	#var fonte2_tem_voltagem = (pot_voltagem2.saida == 0)
	
	var fonte1_em_curto = (1 in hitboxes.fontes_em_curto)
	var fonte2_em_curto = (2 in hitboxes.fontes_em_curto)
	
	var modo_indep_ou_paralelo = ((ch_seletora.estado == 0) or (ch_seletora.estado == 2))
	
	var valor_voltagem1 = 0
	var valor_voltagem2 = 0
	
	var valor_corrente1 = 0
	var valor_corrente2 = 0
	
	if fonte1_em_curto:
		valor_corrente1 = pot_corrente1.saida
	else:
		valor_voltagem1 = pot_voltagem1.saida
		
	if fonte2_em_curto:
		valor_corrente2 = pot_corrente2.saida
	else:
		valor_voltagem2 = pot_voltagem2.saida
		
	if !fonte1_em_curto and modo_indep_ou_paralelo:
		valor_voltagem1 = valor_voltagem2
		
	# ???
	#if !fonte1_tem_voltagem:
	#	valor_corrente1 = 0
	#	
	#if !fonte2_tem_voltagem:
	#	valor_corrente2 = 0
	
	display_voltagem1.text = "%05.2f" % valor_voltagem1
	display_corrente1.text = "%05.2f" % valor_corrente1
	
	display_voltagem2.text = "%05.2f" % valor_voltagem2
	display_corrente2.text = "%05.2f" % valor_corrente2

	#if !(1 in hitboxes.fontes_em_curto):
	#	display_corrente1.text = "00.00"
	#	display_voltagem1.text = "%05.2f" % pot_voltagem1.saida
	#	
	#	if (ch_seletora.estado == 0 or ch_seletora.estado == 2):
	#		display_voltagem1.text = "%05.2f" % pot_voltagem2.saida
	#else:
	#	display_corrente1.text = "%05.2f" % pot_corrente1.saida
	#	display_voltagem1.text = "00.00"
	#
	#if !(2 in hitboxes.fontes_em_curto):
	#	display_corrente2.text = "00.00"
	#	display_voltagem2.text = "%05.2f" % pot_voltagem2.saida
	#else:
	#	display_corrente2.text = "%05.2f" % pot_corrente2.saida
	#	display_voltagem2.text = "00.00"

func _on_pot_voltagem_1_saida_alterada(saida: Variant) -> void:
	escrever_display(display_voltagem1, saida)
	
func _on_pot_voltagem_2_saida_alterada(saida: Variant) -> void:
	escrever_display(display_voltagem2, saida)

func _on_pot_corrente_1_saida_alterada(saida: Variant) -> void:
	escrever_display(display_corrente1, saida)

func _on_pot_corrente_2_saida_alterada(saida: Variant) -> void:
	escrever_display(display_corrente2, saida)

func escrever_display(display, n) -> void:
	display.text = "%05.2f" % n

func _on_botao_on_off_toggled(toggled_on: bool) -> void:
	textoVisivel(toggled_on)
	
func textoVisivel(on) -> void:
	var cor
	if on:
		cor = COR_ON
	else:
		cor = COR_OFF
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(display_voltagem1, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(display_voltagem2, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(display_corrente1, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(display_corrente2, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
