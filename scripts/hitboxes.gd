extends Node

const COR_TRANSPARENTE = Color.TRANSPARENT
const COR_BRANCO = Color.WHITE
const DESLOCAMENTO_Y_TWEEN_SPRITE = 25

@onready var hitboxes = get_children()
@onready var popup_comum = $"../popup_comum"

@onready var sprites_comuns = {
	1: $"../comuns/c1",
	2: $"../comuns/c2",
	3: $"../comuns/c3",
	4: $"../comuns/c4",
	5: $"../comuns/c5",
	6: $"../comuns/c6",
	7: $"../comuns/c7",
	8: $"../comuns/c8",
}

@onready var sprites_curtos = {
	1: $"../curtos/c1",
	2: $"../curtos/c1",
	3: $"../curtos/c1",
	4: $"../curtos/c2",
	5: $"../curtos/c2",
	6: $"../curtos/c2",
}

@export var saida_para_fonte = {	
	1: 1,
	2: 1,
	3: 1,
	
	4: 2,
	5: 2,
	6: 2,
	
	7: 3,
	8: 3,
}

@export var comuns_numeros_ativos = []
@export var fontes_em_curto = []
@export var fontes_com_comum = []
@export var curtos_numeros_ativos = []
@export var fios_na_fonte = []

var mapa_tweens = {}
var posicoes_originais_sprites = {}
var sprites_ativos = []
var numero_selecionado = 0
var hitbox_selecionado = null

func _ready() -> void:
	for hitbox: hitbox_saida in hitboxes:
		if not (hitbox is hitbox_saida):
			continue
		hitbox.emitir_saida.connect(abrir_popup)

func abrir_popup(saida: int, hitbox: hitbox_saida) -> void:
	var tamanho_popup = popup_comum.size
	var tamanho_hitbox = hitbox.size
	
	var deslocamento_x = tamanho_hitbox.x / 2 - tamanho_popup.x / 2
	var deslocamento_y = 100
	var vetor_deslocamento = Vector2(deslocamento_x, -deslocamento_y)
	
	var selecao_possui_comum = saida in comuns_numeros_ativos
	var selecao_possui_curto = saida in curtos_numeros_ativos
	
	var fonte = saida_para_fonte[saida]
	var fonte_possui_comum = fonte in fontes_com_comum
	var fonte_possui_curto = fonte in fontes_em_curto
	
	var habilitar_curto = sprites_curtos.has(saida)
	
	popup_comum.position = hitbox.position + vetor_deslocamento
	popup_comum.visible = true
	
	numero_selecionado = saida
	hitbox_selecionado = hitbox
	popup_comum.clear()
	
	if habilitar_curto:
		if selecao_possui_curto:
			popup_comum.add_item("Remover curto", 2)
		elif (!fonte_possui_comum) and (!fonte_possui_curto):
			popup_comum.add_item("Definir curto", 3)
		
	if selecao_possui_comum:
		popup_comum.add_item("Remover ponto comum", 1)
	elif (!fonte_possui_comum) and (!fonte_possui_curto):
		popup_comum.add_item("Definir ponto comum", 0)
		
	if fios_na_fonte.is_empty():
		popup_comum.add_item("Fio 1", 4)
	else:
		popup_comum.add_item("Fio 2", 5)
	
	if popup_comum.get_item_count() == 0:
		popup_comum.visible = false

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
	
func definir_comum(numero: int) -> void:
	var sprite = sprites_comuns[numero]
	var fonte = saida_para_fonte[numero]
	if !(fonte in fontes_com_comum):
		fontes_com_comum.append(fonte)
	
	if sprite in sprites_ativos:
		return
		
	sprite.visible = true
	sprites_ativos.append(sprite)
	comuns_numeros_ativos.append(numero_selecionado)
	fazer_tween_sprite(sprite, true)
	
func remover_comum(numero: int) -> void:
	var sprite = sprites_comuns[numero]
	var fonte = saida_para_fonte[numero]
	
	if !(sprite in sprites_ativos):
		return
		
	if fonte in fontes_com_comum:
		fontes_com_comum.erase(fonte)
		
	sprites_ativos.erase(sprite)
	comuns_numeros_ativos.erase(numero)
	fazer_tween_sprite(sprite, false)
	
func limitar_comuns() -> void:
	if sprites_ativos.size() > 2:
		var primeiro_numero = comuns_numeros_ativos[0]
		remover_comum(primeiro_numero)
		
func definir_curto(numero: int) -> void:
	var sprite = sprites_curtos[numero]
	if sprite in sprites_ativos:
		return
	
	for id in sprites_curtos.keys():
		if sprites_curtos[id] == sprite:
			curtos_numeros_ativos.append(id)
			
	var fonte = saida_para_fonte[numero]
	if !(fonte in fontes_em_curto):
		fontes_em_curto.append(fonte)
	
	sprite.visible = true
	sprites_ativos.append(sprite)
	fazer_tween_sprite(sprite, true)

func remover_curto(numero: int) -> void:
	var sprite = sprites_curtos[numero]
	if !(sprite in sprites_ativos):
		return
		
	for id in sprites_curtos.keys():
		if sprites_curtos[id] == sprite:
			curtos_numeros_ativos.erase(id)
			
	var fonte = saida_para_fonte[numero]
	if fonte in fontes_em_curto:
		fontes_em_curto.erase(fonte)
		
	sprites_ativos.erase(sprite)
	#curtos_numeros_ativos.erase(numero)
	fazer_tween_sprite(sprite, false)
	
func get_comuns() -> Array:
	return comuns_numeros_ativos
	
func get_comuns_5v() -> Array:
	var comuns_5v = []
	if 7 in comuns_5v:
		comuns_5v.append(7)
	
	if 8 in comuns_5v:
		comuns_5v.append(8)
	
	return comuns_5v

func _on_popup_comum_id_pressed(id: int) -> void:
	var remover = false
	var curto = false
	
	print(id)
	if (id == 1) or (id == 2):
		remover = true
		
	if (id == 3) or (id == 2):
		curto = true
	
	if !curto:
		if remover:
			remover_comum(numero_selecionado)
		else:
			definir_comum(numero_selecionado)
		
	if curto:
		if remover:
			remover_curto(numero_selecionado)
		else:
			definir_curto(numero_selecionado)
	
	limitar_comuns()
	print(comuns_numeros_ativos)
	print(sprites_ativos)
	print(fontes_em_curto)
	
	if id == 4:
		fios_na_fonte.append([numero_selecionado, hitbox_selecionado.position.x])
	
	if id == 5:
		var selecionado1 = fios_na_fonte[0][0]
		var x1 = fios_na_fonte[0][1]  
		
		var selecionado2 = numero_selecionado
		var x2 = hitbox_selecionado.position.x

		fios_na_fonte.clear()
		
		var rect = ColorRect.new()
		rect.color = Color(1, 0, 0)
		rect.size = Vector2(x2 - x1, 10)
		rect.position = Vector2(x1 + 25, 600)
		
		add_child(rect)
		
	
func get_fontes_em_comum() -> Array:
	var fontes_comum = []
	
	for saida in comuns_numeros_ativos:
		var fonte = saida_para_fonte.get(saida, null)
		
		if fonte != null and fonte not in fontes_comum:
			fontes_comum.append(fonte)
	
	return fontes_comum

func get_fontes_em_curto() -> Array:
	var fontes_curto = []
	
	for saida in curtos_numeros_ativos:
		var fonte = saida_para_fonte.get(saida, null)
		
		if fonte != null and fonte not in fontes_curto:
			fontes_curto.append(fonte)
		
	return fontes_curto
