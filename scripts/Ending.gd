## Epilogue — The KEXP session. Frequency restored. Rock 'n' roll confirmed.
extends Node2D

var timer: float = 0.0
var phase: int = 0   # 0=fade in, 1=scene, 2=credits, 3=menu
var alpha: float = 0.0
var credit_scroll: float = 360.0
var stars: Array[Vector3] = []
var crowd_sway: float = 0.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99999
	for i in range(60):
		stars.append(Vector3(rng.randf_range(0, 640), rng.randf_range(0, 200), rng.randf_range(0.3, 1.0)))

func _process(delta: float) -> void:
	timer += delta
	crowd_sway += delta * 0.8

	match phase:
		0:  # Fade in (black to scene)
			alpha = min(timer / 2.0, 1.0)
			if timer >= 2.5:
				phase = 1; timer = 0.0
		1:  # KEXP epilogue scene
			if timer >= 18.0:
				phase = 2; timer = 0.0
		2:  # Credits
			credit_scroll -= delta * 22.0
			if credit_scroll < -800.0:
				phase = 3; timer = 0.0
		3:  # Return to menu after delay
			if timer >= 3.0:
				get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

	if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_back"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color(0.02, 0.02, 0.04))

	match phase:
		0: _draw_fade()
		1: _draw_kexp_scene()
		2: _draw_credits()
		3: _draw_return()

func _draw_fade() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, 1.0 - alpha))
	_draw_text("FREQUENCY RESTORED.", Vector2(185, 160), Color(0.9, 0.85, 0.65, alpha), 2)
	_draw_text("ROCK N ROLL CONFIRMED.", Vector2(170, 180), Color(0.9, 0.85, 0.65, alpha), 2)
	_draw_text("RETURNING TO ORBIT.", Vector2(190, 200), Color(0.9, 0.85, 0.65, alpha), 2)

func _draw_kexp_scene() -> void:
	# Stars
	for s in stars:
		var tw := (sin(timer * 1.3 + s.z * 6.28) * 0.3 + 0.7) * s.z
		draw_circle(Vector2(s.x, s.y), 0.8, Color(1, 1, 1, tw * 0.4))

	# Venue window
	draw_rect(Rect2(80, 40, 480, 200), Color(0.05, 0.06, 0.14))
	draw_rect(Rect2(78, 38, 484, 204), Color(0.25, 0.22, 0.18), false)

	# Night sky through window with the Pyramide glowing
	draw_rect(Rect2(81, 41, 478, 198), Color(0.03, 0.04, 0.10))
	# Pyramide silhouette
	draw_colored_polygon(
		PackedVector2Array([Vector2(310, 220), Vector2(360, 100), Vector2(410, 220)]),
		Color(0.55, 0.45, 0.20)
	)
	# Yield signs glowing on Pyramide
	for i in range(5):
		var yx := 325 + i * 17
		draw_colored_polygon(
			PackedVector2Array([Vector2(yx, 212), Vector2(yx - 5, 220), Vector2(yx + 5, 220)]),
			Color(0.95, 0.65, 0.10, 0.7)
		)

	# Stage (inside venue)
	draw_rect(Rect2(0, 235, 640, 125), Color(0.06, 0.04, 0.04))
	draw_rect(Rect2(0, 233, 640, 5), Color(0.22, 0.16, 0.10))

	# Swaying crowd silhouettes
	for i in range(22):
		var cx := 30 + i * 28
		var ch := 30 + i % 5 * 8
		var sway := sin(crowd_sway + i * 0.4) * 3.0
		draw_rect(Rect2(cx, 240 - ch + sway, 10, ch), Color(0.05, 0.03, 0.04))
		draw_circle(Vector2(cx + 5, 241 - ch + sway), 6, Color(0.05, 0.03, 0.04))

	# KHN and KLEK on stage
	_draw_stage_khn(Vector2(240, 280))
	_draw_stage_klek(Vector2(320, 278))

	# Fabien Peterson (manager) at stage edge, eating a hot dog
	_draw_fabien(Vector2(530, 275))

	# KEXP branding
	_draw_text("KEXP", Vector2(90, 50), Color(0.95, 0.20, 0.20, 0.8), 3)

	# Transmission text
	var tx_alpha: float = min((timer - 12.0) / 2.0, 1.0) if timer > 12.0 else 0.0
	if tx_alpha > 0.0:
		for s in stars:
			var tw := (sin(timer * 2.0 + s.z * 6.28) * 0.4 + 0.6) * s.z
			draw_circle(Vector2(s.x, s.y), 1.2, Color(0.4, 0.8, 1.0, tw * tx_alpha * 0.8))
		_draw_text("TRANSMISSION SENT.", Vector2(190, 15), Color(0.4, 0.85, 1.0, tx_alpha), 2)

func _draw_stage_khn(pos: Vector2) -> void:
	# KHN in performance pose — guitar raised
	var suit := Color(0.08, 0.08, 0.08)
	draw_rect(Rect2(pos.x - 9, pos.y - 36, 18, 22), suit)
	for dx in [-6, 0, 6, -4, 4]:
		for dy in [-32, -24, -18]:
			draw_circle(pos + Vector2(dx, dy), 2, Color(0.95, 0.95, 0.95, 0.8))
	draw_circle(pos + Vector2(0, -44), 9, Color(0.88, 0.78, 0.65))
	draw_line(pos + Vector2(4, -43), pos + Vector2(14, -40), Color(0.72, 0.52, 0.32), 2.5)
	# Guitar raised
	draw_rect(Rect2(pos.x + 12, pos.y - 50, 8, 22), Color(0.55, 0.20, 0.10))
	draw_rect(Rect2(pos.x + 14, pos.y - 62, 4, 14), Color(0.65, 0.45, 0.20))
	# Phosphorescent fret glow
	for f in range(4):
		draw_circle(pos + Vector2(16, -54 + f * 3), 1.5, Color(0.2, 1.0, 0.4, 0.9))

func _draw_stage_klek(pos: Vector2) -> void:
	var suit := Color(0.08, 0.08, 0.08)
	draw_rect(Rect2(pos.x - 9, pos.y - 36, 18, 22), suit)
	for dx in [-6, 0, 6, -4, 4]:
		for dy in [-32, -24, -18]:
			draw_circle(pos + Vector2(dx, dy), 2, Color(0.95, 0.95, 0.95, 0.8))
	draw_circle(pos + Vector2(0, -44), 9, Color(0.88, 0.78, 0.65))
	draw_line(pos + Vector2(-4, -43), pos + Vector2(-14, -40), Color(0.72, 0.52, 0.32), 2.5)
	# Drumsticks in air
	draw_line(pos + Vector2(8, -30), pos + Vector2(20, -18), Color(0.65, 0.42, 0.18), 3)
	draw_line(pos + Vector2(-6, -30), pos + Vector2(-18, -16), Color(0.65, 0.42, 0.18), 3)

func _draw_fabien(pos: Vector2) -> void:
	# Manager — casual pose, hot dog in hand
	var suit := Color(0.22, 0.28, 0.38)
	draw_rect(Rect2(pos.x - 8, pos.y - 32, 16, 20), suit)
	draw_circle(pos + Vector2(0, -40), 8, Color(0.82, 0.70, 0.58))
	# Hot dog
	draw_rect(Rect2(pos.x + 8, pos.y - 28, 18, 6), Color(0.80, 0.55, 0.22))
	draw_rect(Rect2(pos.x + 9, pos.y - 27, 16, 4), Color(0.92, 0.72, 0.30))
	draw_rect(Rect2(pos.x + 10, pos.y - 26, 14, 2), Color(0.75, 0.22, 0.10))

func _draw_credits() -> void:
	var cy := credit_scroll
	var credits := [
		["KHN & KLEK: ANGOR OF THE COSMOS", Color(0.95, 0.90, 0.70), 3],
		["A BEAT 'EM UP FOR TWO PLAYERS", Color(0.80, 0.75, 0.60), 2],
		["", Color(0, 0, 0), 1],
		["BASED ON ANGINE DE POITRINE", Color(0.85, 0.75, 0.55), 2],
		["KHN & KLEK — ARTISTS", Color(0.75, 0.70, 0.55), 1],
		["", Color(0, 0, 0), 1],
		["DOUBLE-NECK MICROTONAL INSTRUMENT", Color(0.70, 0.65, 0.50), 1],
		["CRAFTED BY RAPHAEL LE BRETON OF ALMA", Color(0.70, 0.65, 0.50), 1],
		["150+ HOURS OF LABOR", Color(0.70, 0.65, 0.50), 1],
		["", Color(0, 0, 0), 1],
		["MANAGER: FABIEN PETERSON", Color(0.70, 0.65, 0.50), 1],
		["", Color(0, 0, 0), 1],
		["STAGE 1 — SHERPA", Color(0.65, 0.60, 0.45), 1],
		["STAGE 2 — MATA ZYKLEK", Color(0.65, 0.60, 0.45), 1],
		["STAGE 3 — SARNIEZZ", Color(0.65, 0.60, 0.45), 1],
		["STAGE 4 — UTZP", Color(0.65, 0.60, 0.45), 1],
		["STAGE 5 — YOR ZARAD", Color(0.65, 0.60, 0.45), 1],
		["STAGE 6 — ANGOR", Color(0.65, 0.60, 0.45), 1],
		["", Color(0, 0, 0), 1],
	]

	if GameManager.hotdog_vinyl_unlocked:
		credits.append(["HOTDOG SIDE UNLOCKED", Color(1.0, 0.8, 0.2), 2])
	if GameManager.sardine_vinyl_unlocked:
		credits.append(["SARDINE SIDE UNLOCKED", Color(0.6, 0.9, 0.4), 2])
	if GameManager.tlmep_mode_unlocked:
		credits.append(["TLMEP MODE UNLOCKED", Color(0.4, 0.8, 1.0), 2])

	credits.append(["", Color(0, 0, 0), 1])
	credits.append(["KHN & KLEK: ANGOR OF THE COSMOS", Color(0.85, 0.80, 0.65), 2])
	credits.append(["PRESS ENTER TO RETURN TO MENU", Color(0.55, 0.50, 0.40), 1])

	var y := cy
	for credit in credits:
		var text: String = credit[0]
		var col: Color = credit[1]
		var sc: int = credit[2]
		if text.is_empty():
			y += 16; continue
		var text_w := text.length() * sc * 6
		var tx := (640 - text_w) / 2.0
		if y > -20 and y < 380:
			_draw_text(text, Vector2(tx, y), col, sc)
		y += sc * 8 + 6

func _draw_return() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, min(timer / 2.0, 1.0)))

func _draw_text(text: String, pos: Vector2, color: Color, sc: int) -> void:
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
		" ":[0,0,0,0,0],"-":[0,0,0b01110,0,0],"+":[0,0b00100,0b01110,0b00100,0],
		"!":[0b00100,0b00100,0b00100,0,0b00100],"'":[0b00100,0b00100,0,0,0],
		".":[0,0,0,0,0b00100],",":[0,0,0,0b00100,0b01000],"?":[0b01110,0b10001,0b00110,0,0b00100],
		"&":[0b01100,0b10010,0b01100,0b10010,0b01101],
	}
	var x := pos.x
	for ch in text:
		if ch == " ":
			x += sc * 4; continue
		if not glyphs.has(ch):
			x += sc * 4; continue
		var rows: Array = glyphs[ch]
		for row in range(5):
			var bits: int = rows[row]
			for col in range(5):
				if bits & (1 << (4 - col)):
					draw_rect(Rect2(x + col * sc, pos.y + row * sc, sc, sc), color)
		x += sc * 6
