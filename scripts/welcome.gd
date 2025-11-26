extends Node2D
signal update

@onready var potenciometros = $potenciometros
@onready var seletora = $chave_seletora
@onready var botao = $botao_on_off
@onready var hitboxes = $hitboxes

@onready var pot_voltagem_1 = $potenciometros/pot_voltagem1
@onready var pot_voltagem_2 = $potenciometros/pot_voltagem2

@onready var pot_corrente_1 = $potenciometros/pot_corrente1
@onready var pot_corrente_2 = $potenciometros/pot_corrente2

@onready var pots = [pot_voltagem_1, pot_voltagem_2, pot_corrente_1, pot_corrente_2]

func _ready() -> void:
	for pot: PotenciometroClick in pots:
		pot.saida_alterada.connect(emitir_update_pot)

func _on_chave_seletora_estado_alterado(_novo_estado: Variant, _estado_anterior: Variant) -> void:
	emitir_update()

func _on_botao_on_off_toggled(_toggled_on: bool) -> void:
	emitir_update()
	
func _on_hitboxes_alteracao_feita() -> void:
	emitir_update()

func emitir_update() -> void:
	update.emit()

# stupid!
func emitir_update_pot(_saida) -> void:
	emitir_update()
