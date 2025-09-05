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

@export var numeros_ativos = []

var mapa_tweens = {}
var posicoes_originais_sprites = {}
var sprites_ativos = []
var numero_selecionado = 0

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
	
	var selecao_possui_comum = saida in numeros_ativos
	
	popup_comum.position = hitbox.position + vetor_deslocamento
	popup_comum.visible = true
	
	numero_selecionado = saida
	popup_comum.clear()
	
	if selecao_possui_comum:
		popup_comum.add_item("Remover ponto comum", 1)
	else:
		popup_comum.add_item("Definir ponto comum", 0)

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
	if sprite in sprites_ativos:
		return
		
	sprite.visible = true
	sprites_ativos.append(sprite)
	numeros_ativos.append(numero_selecionado)
	fazer_tween_sprite(sprite, true)
	
func remover_comum(numero: int) -> void:
	var sprite = sprites_comuns[numero]
	if !(sprite in sprites_ativos):
		return
		
	sprites_ativos.erase(sprite)
	numeros_ativos.erase(numero)
	fazer_tween_sprite(sprite, false)
	
func limitar_comuns() -> void:
	if sprites_ativos.size() > 2:
		var primeiro_numero = numeros_ativos[0]
		remover_comum(primeiro_numero)

func _on_popup_comum_id_pressed(id: int) -> void:
	var remover = false
	if id == 1:
		remover = true
	
	if remover:
		remover_comum(numero_selecionado)
	else:
		definir_comum(numero_selecionado)
	
	limitar_comuns()
	print(numeros_ativos)
	print(sprites_ativos)

# funcão antiga que eu tenho medo de remover (ela funcionava, apesar de ser feia)
#func _on_popup_comum_id_pressed(id: int) -> void:
#	var remover = false
#	if id == 1:
#		remover = true
#
#	var sprite_selecionado = sprites_comuns[numero_selecionado]
#	if remover:
#		sprites_ativos.erase(sprite_selecionado)
#		numeros_ativos.erase(numero_selecionado)
#		fazer_tween_sprite(sprite_selecionado, false)
#		print(numeros_ativos)
#		print(sprites_ativos)
#		return
#	
#	if sprite_selecionado in sprites_ativos:
#		return
#
#	sprite_selecionado.visible = true
#	sprites_ativos.append(sprite_selecionado)
#	numeros_ativos.append(numero_selecionado)
#	
#	if sprites_ativos.size() > 2:
#		var primeiro_comum = sprites_ativos[0]
#		fazer_tween_sprite(primeiro_comum, false)
#		sprites_ativos.pop_front()
#		numeros_ativos.pop_front()
#		
#	fazer_tween_sprite(sprite_selecionado, true)
#	print(numeros_ativos)
#	print(sprites_ativos)
