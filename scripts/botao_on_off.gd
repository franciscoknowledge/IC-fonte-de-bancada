extends TextureButton
class_name BotaoOnOff

# constantes:
const POS_INICIAL = Vector2(46, 37)
const POS_FINAL = Vector2(136, 37)

const TEXTURA_OFF = preload("res://imagens/botao_on_off_fundo.png")
const TEXTURA_ON = preload("res://imagens/botao_on_off_fundo2.png")

# variaveis:
@onready var circulo = $circulo

var tween: Tween

# funcoes:
func _pressed() -> void:
	disabled = true
	liga_desliga()

# logica do objeto:
func abilitar_botao() -> void:
	disabled = false

func liga_desliga() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	var posicao
	if button_pressed:
		posicao = POS_FINAL
		texture_normal = TEXTURA_ON
	else:
		posicao = POS_INICIAL
		texture_normal = TEXTURA_OFF
	
	tween.tween_property(circulo, "position", posicao, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(abilitar_botao)
