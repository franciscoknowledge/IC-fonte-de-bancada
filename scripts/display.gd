extends Node

const COR_ON = Color.RED
const COR_OFF = Color.TRANSPARENT

@onready var pot_voltagem1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem2 = $"../potenciometros/pot_voltagem2"
@onready var pot_corrente1 = $"../potenciometros/pot_corrente1"
@onready var pot_corrente2 = $"../potenciometros/pot_corrente2"

@onready var display_voltagem1 = $voltagem1
@onready var display_voltagem2 = $voltagem2
@onready var display_corrente1 = $corrente1
@onready var display_corrente2 = $corrente2

var tween: Tween

func _ready() -> void:
	display_voltagem1.modulate = COR_OFF
	display_voltagem2.modulate = COR_OFF
	display_corrente1.modulate = COR_OFF
	display_corrente2.modulate = COR_OFF

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
