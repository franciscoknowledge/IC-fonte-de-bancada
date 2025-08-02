extends Node

@onready var pot_voltagem1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem2 = $"../potenciometros/pot_voltagem2"
@onready var pot_corrente1 = $"../potenciometros/pot_corrente1"
@onready var pot_corrente2 = $"../potenciometros/pot_corrente2"

@onready var display_voltagem1 = $voltagem1
@onready var display_voltagem2 = $voltagem2
@onready var display_corrente1 = $corrente1
@onready var display_corrente2 = $corrente2
	

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
