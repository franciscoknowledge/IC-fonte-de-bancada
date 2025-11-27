extends Node

const COR_OFF = Color(0.2, 1, 1, 1)
const COR_ON = Color(1, 1, 1, 1)

@onready var root = $".."
@onready var seletora = $"../chave_seletora"
@onready var luz_indep = $luz_indep
@onready var luz_series = $luz_series
@onready var luz_paralell = $luz_paralell
@onready var linha: Line2D = $linha

@onready var estado_para_luz = {
	EnumsGlobal.ESTADOS_FONTE.SERIES: luz_series,
	EnumsGlobal.ESTADOS_FONTE.PARALELL: luz_paralell,
	EnumsGlobal.ESTADOS_FONTE.INDEP: luz_indep,
}

var tween: Tween
var estado_atual: EnumsGlobal.ESTADOS_FONTE

func _ready() -> void:
	for luz: Sprite2D in [luz_indep, luz_series, luz_paralell]:
		luz.modulate = COR_OFF
	
	estado_para_luz[seletora.estado].modulate = COR_ON
	estado_atual = seletora.estado
	tween_luz(null, estado_para_luz[estado_atual])

func _on_chave_seletora_estado_alterado(novo_estado: EnumsGlobal.ESTADOS_FONTE, estado_anterior: EnumsGlobal.ESTADOS_FONTE) -> void:
	var ativar = estado_para_luz[novo_estado]
	var desligar = estado_para_luz[estado_anterior]
	estado_atual = seletora.estado
	
	if root.fonte_ligada:
		tween_luz(ativar, desligar)
	
func _on_botao_on_off_toggled(toggled_on: bool) -> void:
	var luz = estado_para_luz[estado_atual]
	
	if toggled_on:
		tween_luz(luz, null)
	else:
		tween_luz(null, luz)

func tween_luz(luz_ativar: Sprite2D, luz_desligar: Sprite2D) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	if luz_ativar:
		tween.tween_property(luz_ativar, "modulate", COR_ON, 0.2).set_trans(Tween.TRANS_CIRC)
	
	if luz_desligar:
		tween.tween_property(luz_desligar, "modulate", COR_OFF, 0.2).set_trans(Tween.TRANS_CIRC)

func criar_linha() -> void:
	linha.clear_points()
	linha.add_point(seletora.position + seletora.pivot_offset)
	linha.add_point(estado_para_luz[seletora.estado].position)
