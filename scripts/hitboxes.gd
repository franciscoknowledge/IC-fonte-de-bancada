extends Node

const COR_TRANSPARENTE = Color.TRANSPARENT
const COR_BRANCO = Color.WHITE
const DESLOCAMENTO_Y_TWEEN_SPRITE = 25
const TAMANHO_POPUP = Vector2(202, 48)
const ALTURA_FIOS = 110
const LIMITE_FIOS = 4

enum IDS_POPUP {
	DEFINIR_COMUM = 0,
	REMOVER_COMUM = 1,
	
	DEFINIR_CURTO = 3,
	REMOVER_CURTO = 2,
	
	FIO_1 = 4,
	FIO_2 = 5,
}

@onready var LINHA_BASE = $linha_base
@onready var hitboxes = get_children()
@onready var popup_comum = $"../popup_comum"
@onready var seletora = $"../chave_seletora"
@onready var sprites_comuns = {
	enums.SAIDAS.POS_1: $"../comuns/c1",
	enums.SAIDAS.GND_1: $"../comuns/c2",
	enums.SAIDAS.NEG_1: $"../comuns/c3",
	
	enums.SAIDAS.POS_2: $"../comuns/c4",
	enums.SAIDAS.GND_2: $"../comuns/c5",
	enums.SAIDAS.NEG_2: $"../comuns/c6",
	
	enums.SAIDAS.POS_5V: $"../comuns/c7",
	enums.SAIDAS.NEG_5V: $"../comuns/c8",
}

@onready var sprites_curtos = {
	enums.SAIDAS.POS_1: $"../curtos/c1",
	enums.SAIDAS.GND_1: $"../curtos/c1",
	enums.SAIDAS.NEG_1: $"../curtos/c1",
	
	enums.SAIDAS.POS_2: $"../curtos/c2",
	enums.SAIDAS.GND_2: $"../curtos/c2",
	enums.SAIDAS.NEG_2: $"../curtos/c2",
}

@onready var saida_para_hitbox = {
	enums.SAIDAS.POS_1: $hitbox_saida1,
	enums.SAIDAS.GND_1: $hitbox_saida2,
	enums.SAIDAS.NEG_1: $hitbox_saida3,
	
	enums.SAIDAS.POS_2: $hitbox_saida4,
	enums.SAIDAS.GND_2: $hitbox_saida5,
	enums.SAIDAS.NEG_2: $hitbox_saida6,
	
	enums.SAIDAS.POS_5V: $hitbox_saida7,
	enums.SAIDAS.NEG_5V: $hitbox_saida8,
}

@export var comuns_numeros_ativos = []
@export var fontes_em_curto = []
@export var fontes_com_comum = []
@export var linhas = []
@export var curtos_numeros_ativos = []
@export var fios_na_fonte = []
@export var fio_sendo_criado = []

var mapa_tweens = {}
var posicoes_originais_sprites = {}
var sprites_ativos = []
var saida_selecionada = 0
var hitbox_selecionada = null

var quantidade_de_comuns = 2

func _ready() -> void:
	for hitbox in hitboxes:
		if !(hitbox is hitbox_saida): continue
		hitbox.emitir_saida.connect(abrir_popup)
		
func _process(_delta) -> void:
	if get_possui_fontes_interconectadas():
		quantidade_de_comuns = 1
		limitar_comuns()

func abrir_popup(saida: int, hitbox: hitbox_saida) -> void:
	var selecao_possui_comum = saida in comuns_numeros_ativos
	var selecao_possui_curto = saida in curtos_numeros_ativos
	var selecao_possui_fio = false
	
	for fio_array in fios_na_fonte:
		if fio_array.has(saida):
			selecao_possui_fio = true
			break
	
	var fonte = enums.SAIDA_PARA_FONTE[saida]
	var fonte_possui_comum = fonte in fontes_com_comum
	var fonte_possui_curto = fonte in fontes_em_curto
	var habilitar_curto = (fonte != enums.FONTES.FONTE_5V)
	
	saida_selecionada = saida
	hitbox_selecionada = hitbox
	popup_comum.clear()
	
	if selecao_possui_comum:
		popup_comum.add_item("Remover ponto comum", IDS_POPUP.REMOVER_COMUM)
	elif (!fonte_possui_comum) and (!fonte_possui_curto) and (habilitar_curto):
		popup_comum.add_item("Definir ponto comum", IDS_POPUP.DEFINIR_COMUM)
		
	if habilitar_curto:
		if selecao_possui_curto:
			popup_comum.add_item("Remover curto", IDS_POPUP.REMOVER_CURTO)
		elif (!fonte_possui_comum) and (!fonte_possui_curto):
			popup_comum.add_item("Definir curto", IDS_POPUP.DEFINIR_CURTO)
		
		if (seletora.estado == enums.ESTADOS_FONTE.INDEP) and (fios_na_fonte.size() <= LIMITE_FIOS):
			if fio_sendo_criado.is_empty():
				popup_comum.add_item("Fio 1", IDS_POPUP.FIO_1)
			else:
				popup_comum.add_item("Fio 2", IDS_POPUP.FIO_2)
	
	popup_comum.size = TAMANHO_POPUP
	#var tamanho_popup = popup_comum.size
	var tamanho_hitbox = hitbox.size
	
	var deslocamento_x = tamanho_hitbox.x / 2 - TAMANHO_POPUP.x / 2
	var deslocamento_y = 100
	var vetor_deslocamento = Vector2(deslocamento_x, -deslocamento_y)
	
	popup_comum.position = hitbox.position + vetor_deslocamento
	popup_comum.visible = (popup_comum.get_item_count() > 0)

func fazer_tween_sprite(sprite: Sprite2D, ativar: bool) -> void:
	if mapa_tweens.has(sprite):
		mapa_tweens[sprite].kill()
	
	if not posicoes_originais_sprites.has(sprite):
		posicoes_originais_sprites[sprite] = sprite.position
	
	var deslocamento_y = Vector2(0, DESLOCAMENTO_Y_TWEEN_SPRITE)
	var posicao_desejada = posicoes_originais_sprites[sprite]
	var cor_desejada = COR_BRANCO
	
	if ativar:
		sprite.position -= deslocamento_y
		sprite.modulate = COR_TRANSPARENTE
	else:
		posicao_desejada += deslocamento_y
		cor_desejada = COR_TRANSPARENTE
		
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(sprite, "position", posicao_desejada, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(sprite, "modulate", cor_desejada, 0.2).set_trans(Tween.TRANS_CIRC)
	tween.finished.connect(func():
		mapa_tweens.erase(sprite)
		if !ativar:
			sprite.visible = false
	)
	mapa_tweens[sprite] = tween

# comuns
func definir_comum(saida: int) -> void:
	var sprite = sprites_comuns[saida]
	var fonte = enums.SAIDA_PARA_FONTE[saida]
	if !(fonte in fontes_com_comum):
		fontes_com_comum.append(fonte)
	
	if sprite in sprites_ativos:
		return
		
	sprite.visible = true
	sprites_ativos.append(sprite)
	comuns_numeros_ativos.append(saida_selecionada)
	fazer_tween_sprite(sprite, true)
	
func remover_comum(saida: int) -> void:
	var sprite = sprites_comuns[saida]
	var fonte = enums.SAIDA_PARA_FONTE[saida]
	
	if !(sprite in sprites_ativos):
		return
		
	if fonte in fontes_com_comum:
		fontes_com_comum.erase(fonte)
		
	sprites_ativos.erase(sprite)
	comuns_numeros_ativos.erase(saida)
	fazer_tween_sprite(sprite, false)
	
func limitar_comuns() -> void:
	if sprites_ativos.size() > quantidade_de_comuns:
		var primeiro_comum = comuns_numeros_ativos[0]
		remover_comum(primeiro_comum)

# curtos
func definir_curto(saida: int) -> void:
	var sprite = sprites_curtos[saida]
	if sprite in sprites_ativos:
		return
	
	for id in sprites_curtos.keys():
		if sprites_curtos[id] == sprite:
			curtos_numeros_ativos.append(id)
			
	var fonte = enums.SAIDA_PARA_FONTE[saida]
	if !(fonte in fontes_em_curto):
		fontes_em_curto.append(fonte)
	
	sprite.visible = true
	sprites_ativos.append(sprite)
	fazer_tween_sprite(sprite, true)

func remover_curto(saida: int) -> void:
	var sprite = sprites_curtos[saida]
	if !(sprite in sprites_ativos):
		return
		
	for id in sprites_curtos.keys():
		if sprites_curtos[id] == sprite:
			curtos_numeros_ativos.erase(id)
			
	var fonte = enums.SAIDA_PARA_FONTE[saida]
	if fonte in fontes_em_curto:
		fontes_em_curto.erase(fonte)
		
	sprites_ativos.erase(sprite)
	fazer_tween_sprite(sprite, false)

# fios
func adicionar_saida_fio(saida: int) -> void:
	fio_sendo_criado.append(saida)
	fio_sendo_criado.sort()
	
func criar_fio() -> void:
	if fio_sendo_criado.size() != 2:
		fio_sendo_criado.clear()
		return
	
	var fio = [fio_sendo_criado[0], fio_sendo_criado[1]]
	fio.sort()
	
	fio_sendo_criado.clear()
	fios_na_fonte.append(fio)
	
	var tween = create_tween()
	var tamanho_desejado = 15
	
	var linha = LINHA_BASE.duplicate()
	var altura = ALTURA_FIOS - (20 * (fios_na_fonte.size() - 1))
	
	var hitbox_1 = saida_para_hitbox[fio[0]]
	var hitbox_2 = saida_para_hitbox[fio[1]]
	
	var centro_x_1 = hitbox_1.position.x + hitbox_1.size.x / 2
	var centro_y_1 = hitbox_1.position.y + hitbox_1.size.y / 2
	
	var centro_x_2 = hitbox_2.position.x + hitbox_2.size.x / 2
	var centro_y_2 = hitbox_2.position.y + hitbox_2.size.y / 2
	
	var ponto_1 = Vector2(centro_x_1, centro_y_1)
	var ponto_2 = Vector2(centro_x_1, centro_y_1 + altura)
	var ponto_3 = Vector2(centro_x_2, centro_y_1 + altura)
	var ponto_4 = Vector2(centro_x_2, centro_y_2)
	
	linha.width = 0
	
	linha.clear_points()
	linha.add_point(ponto_1)
	linha.add_point(ponto_2)
	linha.add_point(ponto_3)
	linha.add_point(ponto_4)
	
	add_child(linha)
	tween.tween_property(linha, "width", tamanho_desejado, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	linhas.append(linha)

func destruir_todos_fios() -> void:
	fios_na_fonte.clear()
	fio_sendo_criado.clear()
	
	for linha in linhas:
		linha.queue_free()
	
	linhas.clear()

# getters
func get_comuns() -> Array:
	return comuns_numeros_ativos
	
func get_comuns_5v() -> Array:
	var comuns_5v = []
	if enums.SAIDAS.POS_5V in comuns_numeros_ativos:
		comuns_5v.append(enums.SAIDAS.POS_5V)
	
	if enums.SAIDAS.NEG_5V in comuns_numeros_ativos:
		comuns_5v.append(enums.SAIDAS.NEG_5V)
	
	return comuns_5v

func get_fontes_com_comum() -> Array:
	var fontes_comum = []
	
	for saida in comuns_numeros_ativos:
		var fonte = enums.SAIDA_PARA_FONTE.get(saida, null)
		
		if fonte != null and fonte not in fontes_comum:
			fontes_comum.append(fonte)
	
	return fontes_comum

func get_fontes_com_curto() -> Array:
	var fontes_curto = []
	if fontes_curto.is_empty():
		return fontes_curto
	
	for saida in curtos_numeros_ativos:
		var fonte = enums.SAIDA_PARA_FONTE.get(saida, null)
		
		if fonte != null and fonte not in fontes_curto:
			fontes_curto.append(fonte)
		
	return fontes_curto

func get_possui_fontes_interconectadas() -> bool:
	if fios_na_fonte.is_empty():
		return false
	
	for fio in fios_na_fonte:
		var ponto_1 = fio[0]
		var ponto_2 = fio[1]
		if enums.SAIDA_PARA_FONTE[ponto_1] != enums.SAIDA_PARA_FONTE[ponto_2]:
			return true
			
	return false

func _on_popup_comum_id_pressed(id: int) -> void:
	match id:
		IDS_POPUP.DEFINIR_COMUM:
			definir_comum(saida_selecionada)
		IDS_POPUP.REMOVER_COMUM:
			remover_comum(saida_selecionada)
		
		IDS_POPUP.DEFINIR_CURTO:
			definir_curto(saida_selecionada)
		IDS_POPUP.REMOVER_CURTO:
			remover_curto(saida_selecionada)
			
		IDS_POPUP.FIO_1:
			adicionar_saida_fio(saida_selecionada)
		IDS_POPUP.FIO_2:
			adicionar_saida_fio(saida_selecionada)
			criar_fio()
		
	limitar_comuns()

func _on_chave_seletora_estado_alterado(novo_estado: Variant, estado_anterior: Variant) -> void:
	if (novo_estado != enums.ESTADOS_FONTE.INDEP):
		destruir_todos_fios()
		quantidade_de_comuns = 1
	elif (novo_estado == enums.ESTADOS_FONTE.INDEP):
		quantidade_de_comuns = 2
	
	limitar_comuns()
