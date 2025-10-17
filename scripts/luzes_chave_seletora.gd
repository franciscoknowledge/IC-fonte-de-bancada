extends Node

const COR_OFF = Color(0.2, 1, 1, 1)
const COR_ON = Color(1, 1, 1, 1)

@onready var seletora = $"../chave_seletora"
@onready var luz_indep = $luz_indep
@onready var luz_series = $luz_series
@onready var luz_paralell = $luz_paralell
@onready var linha: Line2D = $linha

@onready var luzes = {
	enums.ESTADOS_FONTE.SERIES: luz_series,
	enums.ESTADOS_FONTE.PARALELL: luz_paralell,
	enums.ESTADOS_FONTE.INDEP: luz_indep,
}

var tween: Tween

func _ready() -> void:
	for luz: Sprite2D in [luz_indep, luz_series, luz_paralell]:
		luz.modulate = COR_OFF
	
	luzes[seletora.estado].modulate = COR_ON

func _on_chave_seletora_estado_alterado(novo_estado: Variant, estado_anterior: Variant) -> void:
	var ativar = luzes[novo_estado]
	var desligar = luzes[estado_anterior]
	tween_luz(ativar, desligar)

func tween_luz(luz_ativar, luz_desligar) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(luz_ativar, "modulate", COR_ON, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(luz_desligar, "modulate", COR_OFF, 0.2).set_trans(Tween.TRANS_CIRC)

func criar_linha() -> void:
	linha.clear_points()
	linha.add_point(seletora.position + seletora.pivot_offset)
	linha.add_point(luzes[seletora.estado].position)
