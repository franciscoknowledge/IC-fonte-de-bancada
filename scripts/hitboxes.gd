extends Node

const COR_TRANSPARENTE = Color.TRANSPARENT
const COR_BRANCO = Color.WHITE
const DESLOCAMENTO_Y_TWEEN_SPRITE = 25
const TAMANHO_POPUP = Vector2(202, 48)

enum IDS_POPUP {
	DEFINIR_COMUM = 0,
	REMOVER_COMUM = 1,
	
	DEFINIR_CURTO = 3,
	REMOVER_CURTO = 2,
	
	FIO_1 = 4,
	FIO_2 = 5,
}

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

@export var comuns_numeros_ativos = []
@export var fontes_em_curto = []
@export var fontes_com_comum = []
@export var curtos_numeros_ativos = []
@export var fios_na_fonte = []
@export var fio_sendo_criado = []

var mapa_tweens = {}
var posicoes_originais_sprites = {}
var sprites_ativos = []
var saida_selecionada = 0
var hitbox_selecionada = null

func _ready() -> void:
	for hitbox: hitbox_saida in hitboxes:
		if not (hitbox is hitbox_saida): continue
		hitbox.emitir_saida.connect(abrir_popup)

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
	elif (!fonte_possui_comum) and (!fonte_possui_curto):
		popup_comum.add_item("Definir ponto comum", IDS_POPUP.DEFINIR_COMUM)
		
	if habilitar_curto:
		if selecao_possui_curto:
			popup_comum.add_item("Remover curto", IDS_POPUP.REMOVER_CURTO)
		elif (!fonte_possui_comum) and (!fonte_possui_curto):
			popup_comum.add_item("Definir curto", IDS_POPUP.DEFINIR_CURTO)
		
		if seletora.estado == enums.ESTADOS_FONTE.INDEP:
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
	if sprites_ativos.size() > 2:
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
	fio_sendo_criado.clear()
	fios_na_fonte.append(fio)

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
	
	for saida in curtos_numeros_ativos:
		var fonte = enums.SAIDA_PARA_FONTE.get(saida, null)
		
		if fonte != null and fonte not in fontes_curto:
			fontes_curto.append(fonte)
		
	return fontes_curto

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
	#var remover = false
	#var curto = false
	#
	#print(id)
	#if (id == 1) or (id == 2):
	#	remover = true
	#	
	#if (id == 3) or (id == 2):
	#	curto = true
	#
	#if !curto:
	#	if remover:
	#		remover_comum(saida_selecionada)
	#	else:
	#		definir_comum(saida_selecionada)
	#	
	#if curto:
	#	if remover:
	#		remover_curto(saida_selecionada)
	#	else:
	#		definir_curto(saida_selecionada)
	#
	#limitar_comuns()
	#print(comuns_numeros_ativos)
	#print(sprites_ativos)
	#print(fontes_em_curto)
	#
	#if id == 4:
	#	fios_na_fonte.append([saida_selecionada, hitbox_selecionada.position.x])
	#
	#if id == 5:
	#	var selecionado1 = fios_na_fonte[0][0]
	#	var x1 = fios_na_fonte[0][1]  
	#	
	#	var selecionado2 = saida_selecionada
	#	var x2 = hitbox_selecionada.position.x
	#
	#	fios_na_fonte.clear()
	#	
	#	var rect = ColorRect.new()
	#	rect.color = Color(1, 0, 0)
	#	rect.size = Vector2(x2 - x1, 10)
	#	rect.position = Vector2(x1 + 25, 600)
	#	
	#	add_child(rect)	
