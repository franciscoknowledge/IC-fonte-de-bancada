extends Node

const COR_OFF = Color(0.2, 1, 1, 1)
const COR_ON = Color(1, 1, 1, 1)

@onready var root = $".."

@onready var luz_voltagem_1 = $voltagem1
@onready var luz_corrente_1 = $corrente1
@onready var luz_voltagem_2 = $voltagem2
@onready var luz_corrente_2 = $corrente2

@onready var potenciometros = $"../potenciometros"
@onready var hitboxes = $"../hitboxes"

@onready var pot_voltagem_1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem_2 = $"../potenciometros/pot_voltagem2"

@onready var pot_corrente_1 = $"../potenciometros/pot_corrente1"
@onready var pot_corrente_2 = $"../potenciometros/pot_corrente2"

@onready var fonte_para_potenciometros = {
	EnumsGlobal.FONTES.FONTE_1: [pot_voltagem_1, pot_corrente_1],
	EnumsGlobal.FONTES.FONTE_2: [pot_voltagem_2, pot_corrente_2],
}

@onready var fonte_para_luzes = {
	EnumsGlobal.FONTES.FONTE_1: [luz_voltagem_1, luz_corrente_1],
	EnumsGlobal.FONTES.FONTE_2: [luz_voltagem_2, luz_corrente_2],
}

@onready var luz_para_tween = {
	luz_voltagem_1: null,
	luz_corrente_1: null,
	luz_voltagem_2: null,
	luz_corrente_2: null,
}

func get_modulate(valor: bool) -> Color:
	if valor: return COR_ON
	return COR_OFF
	
func ligar_luzes(fonte: EnumsGlobal.FONTES, ligar_voltagem: bool, ligar_corrente: bool) -> void:
	var luzes = fonte_para_luzes[fonte]
	var luz_voltagem = luzes[0]
	var luz_corrente = luzes[1]
	
	if luz_para_tween[luz_voltagem]:
		luz_para_tween[luz_voltagem].kill()
		
	if luz_para_tween[luz_corrente]:
		luz_para_tween[luz_corrente].kill()
		
	var tween_voltagem = create_tween()
	var tween_corrente = create_tween()
	
	var duracao = 0.2
	tween_voltagem.tween_property(luz_voltagem, "modulate", get_modulate(ligar_voltagem), duracao)
	tween_corrente.tween_property(luz_corrente, "modulate", get_modulate(ligar_corrente), duracao)
	
	luz_para_tween[luz_voltagem] = tween_voltagem
	luz_para_tween[luz_corrente] = tween_corrente

func verificar_fonte(fonte: EnumsGlobal.FONTES) -> void:
	if !root.fonte_ligada: return
	
	var fontes_em_curto = hitboxes.get_fontes_em_curto()
	var pot_corrente = fonte_para_potenciometros[fonte][1]
	
	var fonte_esta_em_curto = (fontes_em_curto.has(fonte))
	var corrente_e_zero = (potenciometros.get_potenciometro_em_zero_rotacao(pot_corrente))
	
	var ligar_luz_voltagem = false
	var ligar_luz_corrente = false
	
	if !(fonte_esta_em_curto or corrente_e_zero):
		ligar_luz_voltagem = true
	else:
		ligar_luz_corrente = true
		
	ligar_luzes(fonte, ligar_luz_voltagem, ligar_luz_corrente)

func verificar_ambas_fontes() -> void:
	verificar_fonte(EnumsGlobal.FONTES.FONTE_1)
	verificar_fonte(EnumsGlobal.FONTES.FONTE_2)

func _ready() -> void:
	for luz: Sprite2D in [luz_voltagem_1, luz_corrente_1, luz_voltagem_2, luz_corrente_2]:
		luz.modulate = COR_OFF

func _on_fonte_update() -> void:
	if !root.fonte_ligada: return
	verificar_ambas_fontes()

func _on_botao_on_off_toggled(toggled_on: bool) -> void:
	if toggled_on:
		verificar_ambas_fontes()
		return
	
	ligar_luzes(EnumsGlobal.FONTES.FONTE_1, toggled_on, toggled_on)
	ligar_luzes(EnumsGlobal.FONTES.FONTE_2, toggled_on, toggled_on)
