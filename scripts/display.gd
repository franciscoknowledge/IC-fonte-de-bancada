extends Node

const COR_ON = Color.RED
const COR_OFF = Color.TRANSPARENT

@onready var hitboxes = $"../hitboxes"

@onready var potenciometros = $"../potenciometros"
@onready var pot_voltagem1 = $"../potenciometros/pot_voltagem1"
@onready var pot_voltagem2 = $"../potenciometros/pot_voltagem2"
@onready var pot_corrente1 = $"../potenciometros/pot_corrente1"
@onready var pot_corrente2 = $"../potenciometros/pot_corrente2"

@onready var display_voltagem1 = $voltagem1
@onready var display_voltagem2 = $voltagem2
@onready var display_corrente1 = $corrente1
@onready var display_corrente2 = $corrente2

@onready var seletora = $"../chave_seletora"

var tween: Tween

func _ready() -> void:
	display_voltagem1.modulate = COR_OFF
	display_voltagem2.modulate = COR_OFF
	display_corrente1.modulate = COR_OFF
	display_corrente2.modulate = COR_OFF

# ruim
func _process(_delta: float) -> void:
	var fontes_em_curto = hitboxes.get_fontes_em_curto()
	
	var fonte_1_em_curto = (fontes_em_curto.has(EnumsGlobal.FONTES.FONTE_1))
	var fonte_2_em_curto = (fontes_em_curto.has(EnumsGlobal.FONTES.FONTE_2))
	
	var modo_serie_ativado = (seletora.estado == EnumsGlobal.ESTADOS_FONTE.SERIES)
	var modo_indep_ativado = (seletora.estado == EnumsGlobal.ESTADOS_FONTE.INDEP)
	
	var corrente_1_zerada = potenciometros.get_potenciometro_em_zero(pot_corrente1)
	
	var voltagem_1 = 0
	var voltagem_2 = 0
	
	var corrente_1 = 0
	var corrente_2 = 0
	
	if fonte_1_em_curto:
		corrente_1 = pot_corrente1.saida
	else:
		voltagem_1 = pot_voltagem1.saida
		
	if fonte_2_em_curto:
		corrente_2 = pot_corrente2.saida
	else:
		voltagem_2 = pot_voltagem2.saida
		
	if !modo_indep_ativado:
		voltagem_1 = voltagem_2
		
	if modo_serie_ativado and corrente_1_zerada:
		voltagem_1 = 0
		
	escrever_displays(voltagem_1, corrente_1, voltagem_2, corrente_2)

func _on_botao_on_off_toggled(toggled_on: bool) -> void:
	tornar_texto_visivel(toggled_on)

func escrever_displays(v_1, c_1, v_2, c_2) -> void:
	display_voltagem1.text = "%05.2f" % v_1
	display_corrente1.text = "%05.2f" % c_1

	display_voltagem2.text = "%05.2f" % v_2
	display_corrente2.text = "%05.2f" % c_2

func tornar_texto_visivel(on) -> void:
	var cor = COR_ON if on else COR_OFF
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(display_voltagem1, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(display_voltagem2, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(display_corrente1, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(display_corrente2, "modulate", cor, 0.2).set_trans(Tween.TRANS_CIRC)
