extends TextureButton

const POS_INICIAL = Vector2(46, 37)
const POS_FINAL = Vector2(136, 37)

const TEXTURA_OFF = preload("res://imagens/botao_on_off_fundo.png")
const TEXTURA_ON = preload("res://imagens/botao_on_off_fundo2.png")

@onready var circulo = $circulo
var tween

func _process(delta: float) -> void:
	if tween and tween.is_running():
		disabled = true
	else:
		disabled = false

func _pressed() -> void:
	test()
	
func test() -> void:
	tween = create_tween()
	var posicao
	
	if button_pressed:
		posicao = POS_FINAL
		texture_normal = TEXTURA_ON
	else:
		posicao = POS_INICIAL
		texture_normal = TEXTURA_OFF
	
	tween.tween_property(circulo, "position", posicao, 0.3).set_trans(Tween.TRANS_CIRC)
