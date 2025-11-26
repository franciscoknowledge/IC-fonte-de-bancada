extends Node
signal alteracao_feita

const COR_TRANSPARENTE = Color.TRANSPARENT
const COR_BRANCO = Color.WHITE

const TAMANHO_POPUP = Vector2(202, 48)

const DESLOCAMENTO_Y_TWEEN_SPRITE = 25
const ALTURA_FIOS = 110
const LIMITE_FIOS = 2

const CENA_FIO = preload("res://cenas/fio.tscn")

#const TEXTURA_FIO_NORMAL = preload("res://imagens/fio_teste.png")
const TEXTURA_FIO_SELECAO = preload("res://imagens/fio_branco.png")
const TEXTURAS_FIOS = [
	preload("res://imagens/fio_1.png"),
	preload("res://imagens/fio_2.png"),
	preload("res://imagens/fio_3.png"),
	preload("res://imagens/fio_4.png"),
	preload("res://imagens/fio_5.png"),
]

enum IDS_POPUP {
	DEFINIR_COMUM = 0,
	REMOVER_COMUM = 1,
	TROCAR_COMUM = 8,
	
	DEFINIR_CURTO = 3,
	REMOVER_CURTO = 2,
	
	FIO_1 = 4,
	FIO_2 = 5,
	
	REMOVER_FIO = 6,
	CANCELAR_FIO = 7,
}

@onready var LINHA_BASE = $linha_base
@onready var setinha_util = $setinha_util
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
@export var fios_fisicos = []
@export var curtos_numeros_ativos = []
@export var fios_na_fonte = []
@export var fio_sendo_criado = []

var mapa_tweens = {}
var posicoes_originais_sprites = {}
var sprites_ativos = []
var saida_selecionada = 0
var hitbox_selecionada = null
var fio_selecionado = []
var comum_para_trocar = 0

var texturas_fios_disponiveis = TEXTURAS_FIOS.duplicate()
var quantidade_de_comuns = 2

func _ready() -> void:
	for membro: Node in hitboxes:
		if membro is HitboxSaida:
			membro.emitir_saida.connect(abrir_popup_para_saida)
	
	#for hitbox in hitboxes:
	#	if !(hitbox is HitboxSaida): continue
	#	hitbox.emitir_saida.connect(abrir_popup_para_saida)
		
func _process(_delta: float) -> void:
	if get_possui_fontes_interconectadas():
		quantidade_de_comuns = 1
		limitar_comuns()
		
func _on_popup_comum_id_pressed(id: int) -> void:
	match id:
		IDS_POPUP.DEFINIR_COMUM:
			definir_comum(saida_selecionada)
			alteracao_feita.emit()
		IDS_POPUP.REMOVER_COMUM:
			remover_comum(saida_selecionada)
			alteracao_feita.emit()
		IDS_POPUP.TROCAR_COMUM:
			trocar_comum(comum_para_trocar, saida_selecionada)
			alteracao_feita.emit()
			
		IDS_POPUP.FIO_1:
			posicionar_setinha(hitbox_selecionada)
			adicionar_saida_fio(saida_selecionada)
		IDS_POPUP.FIO_2:
			adicionar_saida_fio(saida_selecionada)
			criar_fio()
			setinha_util.visible = false
			alteracao_feita.emit()
			
		IDS_POPUP.REMOVER_FIO:
			remover_fio(fio_selecionado, true)
			alteracao_feita.emit()
			reorganizar_alturas()
		IDS_POPUP.CANCELAR_FIO:
			setinha_util.visible = false
			fio_sendo_criado.clear()
		
	limitar_comuns()

func _on_chave_seletora_estado_alterado(novo_estado: Variant, _estado_anterior: Variant) -> void:
	if (novo_estado != enums.ESTADOS_FONTE.INDEP):
		destruir_todos_fios()
		quantidade_de_comuns = 1
	else:
		quantidade_de_comuns = 2
		
	for comum: enums.SAIDAS in comuns_numeros_ativos.duplicate():
		if enums.SAIDA_PARA_FONTE[comum] == enums.FONTES.FONTE_5V:
			remover_comum(comum)
	
	alteracao_feita.emit()
	limitar_comuns()

func _on_popup_comum_popup_hide() -> void:
	mudar_textura_dos_fios()

func preparar_popup() -> void:
	popup_comum.clear()
	popup_comum.size = TAMANHO_POPUP
	
func mostrar_popup(posicao: Vector2) -> void:
	popup_comum.position = posicao
	popup_comum.visible = (popup_comum.get_item_count() > 0)
	
func abrir_popup_para_saida(saida: int, hitbox: HitboxSaida) -> void:
	preparar_popup()
	saida_selecionada = saida
	hitbox_selecionada = hitbox
	
	var fonte = enums.SAIDA_PARA_FONTE[saida]
	var fonte_possui_comum = fonte in fontes_com_comum
	var fonte_possui_curto = fonte in fontes_em_curto
	var e_fonte_5v = (fonte == enums.FONTES.FONTE_5V)
	
	var comum_presente
	
	var selecao_possui_comum = saida in comuns_numeros_ativos
	#var selecao_possui_curto = saida in curtos_numeros_ativos
	#var selecao_possui_fio = false
	
	var fio_resultante = []
	var fio_e_igual = false
	var fio_redundante = false
	
	if !fio_sendo_criado.is_empty():
		fio_resultante.append(fio_sendo_criado[0])
		fio_resultante.append(saida)
		fio_resultante.sort()
		
		if fios_na_fonte.has(fio_resultante):
			fio_e_igual = true
			
		if (fio_resultante[0] == fio_resultante[1]):
			fio_redundante = true
			
	for comum: enums.SAIDAS in comuns_numeros_ativos:
		if enums.SAIDA_PARA_FONTE[comum] == fonte:
			comum_presente = comum
			break
	
	var pode_definir_comum = (!fonte_possui_comum) and (!fonte_possui_curto) and ((not e_fonte_5v) or seletora.estado == enums.ESTADOS_FONTE.INDEP)
	#var pode_definir_curto = (!fonte_possui_comum) and (!fonte_possui_curto)
	var pode_definir_fios = (seletora.estado == enums.ESTADOS_FONTE.INDEP) and (fios_na_fonte.size() <= LIMITE_FIOS)
	
	if selecao_possui_comum:
		popup_comum.add_item("Remover ponto comum", IDS_POPUP.REMOVER_COMUM)
	elif pode_definir_comum:
		popup_comum.add_item("Definir ponto comum", IDS_POPUP.DEFINIR_COMUM)
		
	if !selecao_possui_comum and fontes_com_comum and comum_presente:
		comum_para_trocar = comum_presente
		popup_comum.add_item("Trocar comum", IDS_POPUP.TROCAR_COMUM)
	
	if pode_definir_fios:
		if fio_sendo_criado.is_empty():
			popup_comum.add_item("Fio 1", IDS_POPUP.FIO_1)
		elif !fio_e_igual and !fio_redundante:
			popup_comum.add_item("Fio 2", IDS_POPUP.FIO_2)
				
	if !fio_sendo_criado.is_empty():
		popup_comum.add_item("Cancelar fio", IDS_POPUP.CANCELAR_FIO)
	
	var tamanho_hitbox = hitbox.size
	
	var deslocamento_x = tamanho_hitbox.x / 2 - TAMANHO_POPUP.x / 2
	var deslocamento_y = 100
	var vetor_deslocamento = Vector2(deslocamento_x, -deslocamento_y)
	
	mostrar_popup(hitbox.position + vetor_deslocamento)

func abrir_popup_para_fio(fio: Line2D, saidas: Array) -> void:
	preparar_popup()
	popup_comum.add_item("Remover fio", IDS_POPUP.REMOVER_FIO)
	fio_selecionado = fio
	
	var hitbox_1 = saida_para_hitbox[saidas[0]]
	var hitbox_2 = saida_para_hitbox[saidas[1]]
	
	var largura_popup = TAMANHO_POPUP.x
	var centro_1 = hitbox_1.position.x + hitbox_1.size.x / 2
	var centro_2 = hitbox_2.position.x + hitbox_2.size.x / 2
	
	var posicao_x = (centro_1 + centro_2 - largura_popup) / 2
	var posicao_y = hitbox_1.position.y - 100
	
	fio.texture = TEXTURA_FIO_SELECAO
	mostrar_popup(Vector2(posicao_x, posicao_y))

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
		alteracao_feita.emit()

func trocar_comum(inicio: int, fim: int) -> void:
	remover_comum(inicio)
	definir_comum(fim)

# fios
func adicionar_saida_fio(saida: int) -> void:
	fio_sendo_criado.append(saida)
	fio_sendo_criado.sort()
	
func criar_fio() -> void:
	if fio_sendo_criado.size() != 2:
		fio_sendo_criado.clear()
		return
		
	var fio_fisico: FioFisico = CENA_FIO.instantiate()
	add_child(fio_fisico)
	
	var fio = [fio_sendo_criado[0], fio_sendo_criado[1]]
	fio.sort()
	
	fio_sendo_criado.clear()
	fios_na_fonte.append(fio)
	
	var tween = create_tween()
	var tamanho_desejado = fio_fisico.tamanho
	
	#var linha = LINHA_BASE.duplicate()
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
	
	fio_fisico.clear_points()
	fio_fisico.width = 0
	
	fio_fisico.add_point(ponto_1)
	fio_fisico.add_point(ponto_2)
	fio_fisico.add_point(ponto_3)
	fio_fisico.add_point(ponto_4)
	
	fio_fisico.redimensionar_hitboxes()
	fio_fisico.fio_clicado.connect(abrir_popup_para_fio)
	
	tween.tween_property(fio_fisico, "width", tamanho_desejado, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	fios_fisicos.append(fio_fisico)
	fio_fisico.saidas = fio
	fio_fisico.armazenar_textura(pegar_textura_fio_disponivel())

func destruir_todos_fios() -> void:
	for fio_fisico: FioFisico in fios_fisicos.duplicate():
		remover_fio(fio_fisico, true)
	
	fios_fisicos.clear()
	fios_na_fonte.clear()
	fio_sendo_criado.clear()

func remover_fio(fio: FioFisico, fazer_tween: bool) -> void:
	var saidas = fio.saidas
	var indice = fios_na_fonte.find(saidas)
	if indice < 0: return
	
	fio.desabilitar = true
	fios_na_fonte.remove_at(indice)
	fios_fisicos.remove_at(indice)
	armazenar_textura_fio(fio.textura_armazenada)
	
	if fazer_tween:
		var tween = create_tween()
		tween.tween_property(fio, "width", 0, 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		tween.tween_callback(fio.queue_free)
	else:
		fio.queue_free()

func mudar_textura_dos_fios() -> void:
	if fios_fisicos.is_empty(): return
	
	for fio_fisico: FioFisico in fios_fisicos:
		#fio_fisico.texture = TEXTURA_FIO_NORMAL
		fio_fisico.usar_textura_armazenada()

func comparar_ordem_texturas(textura_a: Resource, textura_b: Resource) -> bool:
	# coloquei algumas anotações, pois essa função é dependente do nome do arquivo
	# e pode ser meio confusa por isso
	# -> fio_1.png, fio_2.png, fio_3.png, . . .
	# ela usa o fato do numero ser separado pelo "_" para organizar a lista de texturas
	
	# pega o nome do arquivo do resource, ex: fio_1.png
	var arquivo_a = textura_a.resource_path.get_file()
	var arquivo_b = textura_b.resource_path.get_file()
	
	# tira a extensão do nome do arquivo, ex: fio_1
	var base_a = arquivo_a.get_basename()
	var base_b = arquivo_b.get_basename()
	
	# base_x.split("_") separa a string entre "fio" e "1"
	# o segundo elemento do array é o numero
	# usamos int() para converter isso para um número inteiro
	var n_a = int(base_a.split("_")[1])
	var n_b = int(base_b.split("_")[1])
	
	# é feita comparação de qual é maior para organizar a lista, priorizando o menor número
	return n_a < n_b

func organizar_lista_texturas() -> void:
	texturas_fios_disponiveis.sort_custom(comparar_ordem_texturas)

func posicionar_setinha(hitbox) -> void:
	setinha_util.visible = true
	setinha_util.position = hitbox.position + hitbox.size / 2 + Vector2(0, 70)

func pegar_textura_fio_disponivel() -> Resource:
	var textura = texturas_fios_disponiveis[0]
	texturas_fios_disponiveis.erase(textura)
	return textura

func reorganizar_alturas() -> void:
	for i in range(fios_fisicos.size()):
		var fio_fisico: FioFisico = fios_fisicos[i]
		var saida_1 = fio_fisico.saidas[0]
		var saida_2 = fio_fisico.saidas[1]
		
		var hitbox_1 = saida_para_hitbox[saida_1]
		var hitbox_2 = saida_para_hitbox[saida_2]
		
		var centro_y_1 = hitbox_1.position.y + hitbox_1.size.y / 2
		var centro_y_2 = hitbox_2.position.y + hitbox_2.size.y / 2
		
		var ponto_2 = fio_fisico.points[1]
		var ponto_3 = fio_fisico.points[2]
		
		var altura = ALTURA_FIOS - (20 * i)
		
		ponto_2.y = centro_y_1 + altura
		ponto_3.y = centro_y_2 + altura
		
		fio_fisico.points[1] = ponto_2
		fio_fisico.points[2] = ponto_3
		
		fio_fisico.redimensionar_hitboxes()

func armazenar_textura_fio(textura: Resource) -> void:
	texturas_fios_disponiveis.append(textura)
	organizar_lista_texturas()

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
	
	for saida: enums.SAIDAS in comuns_numeros_ativos:
		var fonte = enums.SAIDA_PARA_FONTE.get(saida, null)
		
		if fonte != null and fonte not in fontes_comum:
			fontes_comum.append(fonte)
	
	return fontes_comum

func get_fontes_em_curto() -> Array:
	fontes_em_curto = []
	if not fios_na_fonte:
		return []
	
	if fios_na_fonte.is_empty():
		return fontes_em_curto
	
	for fio in fios_na_fonte:
		if fio == [enums.SAIDAS.POS_1, enums.SAIDAS.NEG_1]:
			fontes_em_curto.append(enums.FONTES.FONTE_1)
			continue
			
		if fio == [enums.SAIDAS.POS_2, enums.SAIDAS.NEG_2]:
			fontes_em_curto.append(enums.FONTES.FONTE_2)
			continue
			
	return fontes_em_curto

func get_possui_fontes_interconectadas() -> bool:
	if not fios_na_fonte:
		return false
	
	if fios_na_fonte.is_empty():
		return false
	
	for fio in fios_na_fonte:
		var ponto_1 = fio[0]
		var ponto_2 = fio[1]
		if enums.SAIDA_PARA_FONTE[ponto_1] != enums.SAIDA_PARA_FONTE[ponto_2]:
			return true
			
	return false
