extends TextureButton
class_name chave_seletora

signal estado_alterado(novo_estado, estado_anterior)

const rotacoes = {
	enums.ESTADOS_FONTE.SERIES: deg_to_rad(60),
	enums.ESTADOS_FONTE.INDEP: deg_to_rad(90),
	enums.ESTADOS_FONTE.PARALELL: deg_to_rad(120),
}

@export var estado = enums.ESTADOS_FONTE.INDEP

var tween: Tween

func _ready() -> void:
	rotation = rotacoes[estado]

func _pressed() -> void:
	var anterior = estado
	estado = estado + 1
	estado = wrapi(estado, 1, 4)
	
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
