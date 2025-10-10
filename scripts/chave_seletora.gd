extends TextureButton
class_name chave_seletora

signal estado_alterado(novo_estado, estado_anterior)

enum ESTADOS {
	SERIES,
	INDEP,
	PARALELL,
}

const rotacoes = {
	ESTADOS.SERIES : deg_to_rad(60),
	ESTADOS.INDEP : deg_to_rad(90),
	ESTADOS.PARALELL : deg_to_rad(120),
}

@export var estado = ESTADOS.INDEP

var tween: Tween

func _ready() -> void:
	rotation = rotacoes[estado]

func _pressed() -> void:
	var anterior = estado
	estado = estado + 1
	estado = wrapi(estado, 0, ESTADOS.size())
	
	estado_alterado.emit(estado, anterior)
	tween_rotacao()
	
func abilitar_botao() -> void:
	disabled = false

func tween_rotacao() -> void:
	disabled = true
	var rotacao = rotacoes[estado]
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "rotation", rotacao, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(abilitar_botao)
