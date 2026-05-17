## Character select screen — shown in 1P mode to choose KHN or KLEK.
## 2P mode skips here (KHN=P1, KLEK=P2 always).
extends Node2D

var selected: int = 0  # 0=KHN, 1=KLEK
var pulse: float = 0.0
var confirmed: bool = false

const KHN_LORE := "KHN\nThe Harmonic Fighter\n\nWields the double-neck microtonal\nguitar as both cannon and club.\nSPECIAL: LOOP STATION\nShockwave rings that radiate\noutward, striking all enemies."

const KLEK_LORE := "KLEK\nThe Rhythmic Disruptor\n\nDrumstick combos + cymbal throws\nafter every 3-hit chain.\nSPECIAL: ODD METER\nDisrupts all enemy AI timing,\ncausing stumble and desync."

func _process(delta: float) -> void:
	pulse += delta * 2.2
	if confirmed:
		return
	if Input.is_action_just_pressed("p1_left") or Input.is_action_just_pressed("p1_right"):
		selected = 1 - selected
	if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("p1_attack"):
		_confirm()
	queue_redraw()

func _confirm() -> void:
	confirmed = true
	GameManager.selected_character = selected  # 0=KHN, 1=KLEK (stored for GameScene)
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, 640, 360), Color(0.04, 0.04, 0.07))

	# Title
	_draw_text("SELECT YOUR FIGHTER", Vector2(175, 18), Color(0.9, 0.85, 0.65), 2)
	draw_line(Vector2(60, 38), Vector2(580, 38), Color(0.45, 0.38, 0.28, 0.5), 1.0)

	# Panel backgrounds
	var khn_col := Color(0.15, 0.12, 0.08) if selected == 0 else Color(0.08, 0.07, 0.06)
	var klek_col := Color(0.15, 0.12, 0.08) if selected == 1 else Color(0.08, 0.07, 0.06)
	draw_rect(Rect2(40, 50, 260, 270), khn_col)
	draw_rect(Rect2(340, 50, 260, 270), klek_col)

	# Selection highlight
	var glow: float = abs(sin(pulse)) * 0.4 + 0.2
	if selected == 0:
		draw_rect(Rect2(40, 50, 260, 270), Color(0.8, 0.65, 0.2, glow * 0.3))
		draw_rect(Rect2(40, 50, 260, 1), Color(0.8, 0.65, 0.2, glow))
		draw_rect(Rect2(40, 319, 260, 1), Color(0.8, 0.65, 0.2, glow))
		draw_rect(Rect2(40, 50, 1, 270), Color(0.8, 0.65, 0.2, glow))
		draw_rect(Rect2(299, 50, 1, 270), Color(0.8, 0.65, 0.2, glow))
	else:
		draw_rect(Rect2(340, 50, 260, 270), Color(0.8, 0.65, 0.2, glow * 0.3))
		draw_rect(Rect2(340, 50, 260, 1), Color(0.8, 0.65, 0.2, glow))
		draw_rect(Rect2(340, 319, 260, 1), Color(0.8, 0.65, 0.2, glow))
		draw_rect(Rect2(340, 50, 1, 270), Color(0.8, 0.65, 0.2, glow))
		draw_rect(Rect2(599, 50, 1, 270), Color(0.8, 0.65, 0.2, glow))

	# KHN silhouette
	_draw_khn_figure(Vector2(170, 210))
	# KLEK silhouette
	_draw_klek_figure(Vector2(470, 210))

	# Lore text
	var lore := KHN_LORE if selected == 0 else KLEK_LORE
	var lore_x := 50 if selected == 0 else 350
	var lines := lore.split("\n")
	for i in range(lines.size()):
		var line_col := Color(0.95, 0.90, 0.70) if i == 0 else (
				Color(0.65, 0.58, 0.42) if i == 1 else Color(0.75, 0.70, 0.60))
		var sc := 2 if i == 0 else 1
		_draw_text(lines[i], Vector2(lore_x, 330 + i * 14 - (sc - 1) * 3), line_col, sc)

	# Arrows
	_draw_text("< KHN", Vector2(55, 185), Color(0.7, 0.6, 0.4, 0.8), 2)
	_draw_text("KLEK >", Vector2(450, 185), Color(0.7, 0.6, 0.4, 0.8), 2)

	# Confirm hint
	var blink: bool = abs(sin(pulse * 3.0)) > 0.5
	if blink:
		_draw_text("PRESS J TO CONFIRM", Vector2(210, 345), Color(0.85, 0.78, 0.55), 1)

func _draw_khn_figure(pos: Vector2) -> void:
	# Dark suit + guitar
	var suit := Color(0.10, 0.10, 0.13)
	var skin := Color(0.88, 0.78, 0.65)
	var dot  := Color(0.9, 0.9, 0.9, 0.8)
	var guitar := Color(0.55, 0.20, 0.10)
	var neck_col := Color(0.65, 0.45, 0.20)

	draw_rect(Rect2(pos.x - 9, pos.y - 16, 7, 16), suit)
	draw_rect(Rect2(pos.x + 2, pos.y - 16, 7, 16), suit)
	draw_rect(Rect2(pos.x - 11, pos.y - 5, 9, 5), Color(0.25, 0.18, 0.10))
	draw_rect(Rect2(pos.x + 2, pos.y - 5, 9, 5), Color(0.25, 0.18, 0.10))
	draw_rect(Rect2(pos.x - 10, pos.y - 36, 20, 20), suit)
	for dp in [Vector2(-5, -28), Vector2(3, -30), Vector2(-2, -22), Vector2(4, -24)]:
		draw_circle(pos + dp, 2.0, dot)
	draw_circle(pos + Vector2(0, -44), 10.0, skin)
	# Cone head (white mask)
	var hcy := pos.y - 44
	for row in range(12):
		var w2 := int(row * 10.0 / 12.0)
		draw_line(Vector2(pos.x - w2, hcy - 10 + row), Vector2(pos.x + w2, hcy - 10 + row), Color(0.92, 0.88, 0.78), 1.0)
	draw_circle(pos + Vector2(3, -44), 2.0, Color(0.15, 0.1, 0.05))
	draw_line(pos + Vector2(3, -43), pos + Vector2(15, -40), Color(0.72, 0.52, 0.32), 2.5)
	# Guitar
	draw_rect(Rect2(pos.x + 12, pos.y - 38, 12, 18), guitar)
	draw_rect(Rect2(pos.x + 15, pos.y - 64, 4, 28), neck_col)
	for f in range(3):
		draw_circle(pos + Vector2(17, -46 - f * 6), 1.5, Color(0.2, 1.0, 0.4, 0.9))

func _draw_klek_figure(pos: Vector2) -> void:
	# White robe + round black head
	var robe := Color(0.88, 0.84, 0.78)
	var shoe := Color(0.18, 0.14, 0.12)
	var dot  := Color(0.18, 0.14, 0.14)

	draw_rect(Rect2(pos.x - 10, pos.y - 18, 8, 18), robe)
	draw_rect(Rect2(pos.x + 2, pos.y - 18, 8, 18), robe)
	draw_rect(Rect2(pos.x - 12, pos.y - 5, 10, 5), shoe)
	draw_rect(Rect2(pos.x + 2, pos.y - 5, 10, 5), shoe)
	draw_rect(Rect2(pos.x - 12, pos.y - 36, 24, 20), robe)
	for dp in [Vector2(-5, -28), Vector2(3, -30), Vector2(-2, -22), Vector2(5, -25), Vector2(-7, -20)]:
		draw_circle(pos + dp, 2.0, dot)
	# Round black head
	draw_circle(pos + Vector2(0, -46), 12.0, Color(0.10, 0.08, 0.11))
	# Triangle symbol (yellow)
	for row in range(5):
		var w2 := row
		draw_line(Vector2(pos.x - w2, pos.y - 50 + row), Vector2(pos.x + w2, pos.y - 50 + row), Color(0.85, 0.75, 0.2), 1.0)
	# Eyes
	draw_circle(pos + Vector2(-4, -47), 2.0, Color(0.85, 0.80, 0.75))
	draw_circle(pos + Vector2(4, -47), 2.0, Color(0.85, 0.80, 0.75))
	# Drumsticks
	draw_line(pos + Vector2(-8, -32), pos + Vector2(-24, -46), Color(0.65, 0.42, 0.18), 3.0)
	draw_line(pos + Vector2(8, -32), pos + Vector2(24, -48), Color(0.65, 0.42, 0.18), 3.0)

func _draw_text(text: String, pos: Vector2, color: Color, sc: int = 1) -> void:
	var glyphs: Dictionary = {
		"A":[0b01110,0b10001,0b11111,0b10001,0b10001],"B":[0b11110,0b10001,0b11110,0b10001,0b11110],
		"C":[0b01111,0b10000,0b10000,0b10000,0b01111],"D":[0b11110,0b10001,0b10001,0b10001,0b11110],
		"E":[0b11111,0b10000,0b11110,0b10000,0b11111],"F":[0b11111,0b10000,0b11110,0b10000,0b10000],
		"G":[0b01111,0b10000,0b10011,0b10001,0b01111],"H":[0b10001,0b10001,0b11111,0b10001,0b10001],
		"I":[0b11111,0b00100,0b00100,0b00100,0b11111],"J":[0b11111,0b00010,0b00010,0b10010,0b01100],
		"K":[0b10001,0b10010,0b11100,0b10010,0b10001],"L":[0b10000,0b10000,0b10000,0b10000,0b11111],
		"M":[0b10001,0b11011,0b10101,0b10001,0b10001],"N":[0b10001,0b11001,0b10101,0b10011,0b10001],
		"O":[0b01110,0b10001,0b10001,0b10001,0b01110],"P":[0b11110,0b10001,0b11110,0b10000,0b10000],
		"Q":[0b01110,0b10001,0b10101,0b10010,0b01101],"R":[0b11110,0b10001,0b11110,0b10010,0b10001],
		"S":[0b01111,0b10000,0b01110,0b00001,0b11110],"T":[0b11111,0b00100,0b00100,0b00100,0b00100],
		"U":[0b10001,0b10001,0b10001,0b10001,0b01110],"V":[0b10001,0b10001,0b10001,0b01010,0b00100],
		"W":[0b10001,0b10001,0b10101,0b11011,0b10001],"X":[0b10001,0b01010,0b00100,0b01010,0b10001],
		"Y":[0b10001,0b01010,0b00100,0b00100,0b00100],"Z":[0b11111,0b00010,0b00100,0b01000,0b11111],
		"0":[0b01110,0b10011,0b10101,0b11001,0b01110],"1":[0b00110,0b01010,0b00100,0b00100,0b01110],
		"2":[0b01110,0b10001,0b00110,0b01000,0b11111],"3":[0b11110,0b00001,0b01110,0b00001,0b11110],
		"4":[0b00110,0b01010,0b10010,0b11111,0b00010],"5":[0b11111,0b10000,0b11110,0b00001,0b11110],
		"6":[0b01110,0b10000,0b11110,0b10001,0b01110],"7":[0b11111,0b00001,0b00010,0b00100,0b00100],
		"8":[0b01110,0b10001,0b01110,0b10001,0b01110],"9":[0b01110,0b10001,0b01111,0b00001,0b01110],
		" ":[0,0,0,0,0],"-":[0,0,0b01110,0,0],"<":[0,0b00010,0b01100,0b00010,0],
		">":[0,0b01000,0b00110,0b01000,0],"!":[0b00100,0b00100,0b00100,0,0b00100],
		"/":[0,0b00001,0b00010,0b00100,0b01000],"+":[0,0b00100,0b01110,0b00100,0],
		".":[0,0,0,0,0b00100],",":[0,0,0,0b00100,0b01000],"'":[0b00100,0b00100,0,0,0],
	}
	var x := pos.x
	for ch in text:
		var key := ch.to_upper()
		if key == " ":
			x += sc * 4; continue
		if not glyphs.has(key):
			x += sc * 6; continue
		var rows: Array = glyphs[key]
		for row in range(5):
			var bits: int = rows[row]
			for col in range(5):
				if bits & (1 << (4 - col)):
					draw_rect(Rect2(x + col * sc, pos.y + row * sc, sc, sc), color)
		x += sc * 6
