## Main menu — pixel art title screen with 1P/2P selection
extends Node2D

var selected_option: int = 0  # 0=1P, 1=2P
var input_timer: float = 0.0
var stars: Array[Vector3] = []  # x, y, brightness
var title_pulse: float = 0.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in range(80):
		stars.append(Vector3(rng.randf_range(0, 640), rng.randf_range(0, 280), rng.randf_range(0.3, 1.0)))
	GameManager.play_music(GameManager.MUSIC_GRAVITY_BOUND)

func _process(delta: float) -> void:
	title_pulse += delta * 1.8
	input_timer -= delta
	if input_timer <= 0.0:
		if Input.is_action_just_pressed("p1_up") or Input.is_action_just_pressed("p1_down"):
			selected_option = 1 - selected_option
			input_timer = 0.15
		if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("p1_attack"):
			GameManager.start_game(selected_option + 1)
	queue_redraw()

func _draw() -> void:
	# Deep space background
	draw_rect(Rect2(0, 0, 640, 360), Color(0.02, 0.02, 0.05))

	# Stars
	for s in stars:
		var twinkle := (sin(title_pulse * 1.3 + s.z * 6.28) * 0.3 + 0.7) * s.z
		draw_circle(Vector2(s.x, s.y), 0.8 + s.z * 0.6, Color(1, 1, 1, twinkle))

	# Two silhouettes drifting in space
	var sway := sin(title_pulse * 0.7) * 3.0
	_draw_silhouette(Vector2(220, 180 + sway), true)
	_draw_silhouette(Vector2(300, 185 - sway), false)

	# Title — KHN & KLEK
	_draw_title_text("KHN & KLEK", Vector2(80, 60), Color(0.95, 0.90, 0.70), 4)
	_draw_title_text("ANGOR OF THE COSMOS", Vector2(105, 100), Color(0.85, 0.65, 0.40), 2)

	# Subtitle
	_draw_big_text("A BEAT 'EM UP FOR TWO PLAYERS", Vector2(130, 122), Color(0.60, 0.55, 0.45), 1)

	# Separator
	draw_line(Vector2(60, 135), Vector2(580, 135), Color(0.45, 0.38, 0.28, 0.6), 1.0)

	# Menu options
	var p1_col := Color(1.0, 0.9, 0.5) if selected_option == 0 else Color(0.5, 0.5, 0.4)
	var p2_col := Color(1.0, 0.9, 0.5) if selected_option == 1 else Color(0.5, 0.5, 0.4)

	if selected_option == 0:
		draw_rect(Rect2(195, 150, 250, 18), Color(0.3, 0.25, 0.15, 0.5))
	_draw_big_text("1 PLAYER  (KHN)", Vector2(200, 153), p1_col, 2)

	if selected_option == 1:
		draw_rect(Rect2(195, 172, 250, 18), Color(0.3, 0.25, 0.15, 0.5))
	_draw_big_text("2 PLAYERS (KHN+KLEK)", Vector2(200, 175), p2_col, 2)

	# Controls hint
	_draw_big_text("WASD/ARROWS  J=PUNCH  K=KICK  L=JUMP  I=SPECIAL", Vector2(60, 200), Color(0.4, 0.4, 0.35), 1)
	_draw_big_text("P2: ARROWS+NUMPAD4-7", Vector2(60, 210), Color(0.4, 0.4, 0.35), 1)

	# Press enter
	var blink = abs(sin(title_pulse * 2.5)) > 0.5
	if blink:
		_draw_big_text("PRESS ENTER TO START", Vector2(190, 238), Color(0.9, 0.85, 0.65), 2)

	# Score
	if GameManager.high_score > 0:
		_draw_big_text("HI-SCORE: %07d" % GameManager.high_score, Vector2(230, 260), Color(0.65, 0.60, 0.50), 1)

	# Credits
	_draw_big_text("BASED ON ANGINE DE POITRINE", Vector2(185, 285), Color(0.35, 0.32, 0.28), 1)
	_draw_big_text("KHN & KLEK: ANGOR OF THE COSMOS", Vector2(175, 293), Color(0.35, 0.32, 0.28), 1)

	# Yield sign motif corners
	for corner in [Vector2(20, 30), Vector2(600, 30), Vector2(20, 320), Vector2(600, 320)]:
		draw_colored_polygon(
			PackedVector2Array([corner + Vector2(0, -12), corner + Vector2(-10, 6), corner + Vector2(10, 6)]),
			Color(0.85, 0.65, 0.1, 0.5)
		)

func _draw_silhouette(pos: Vector2, facing_right: bool) -> void:
	var fx := 1 if facing_right else -1
	# Black polka-dot suit silhouette (tiny, in space)
	draw_rect(Rect2(pos.x - 8, pos.y - 28, 16, 22), Color(0.06, 0.06, 0.08))
	for dx in [-5, 0, 5, -3, 3]:
		for dy in [-22, -16, -10]:
			draw_circle(pos + Vector2(dx, dy), 1.5, Color(0.18, 0.18, 0.22))
	draw_circle(pos + Vector2(0, -36), 8, Color(0.06, 0.06, 0.08))
	draw_line(pos + Vector2(fx * 2, -36), pos + Vector2(fx * 11, -33), Color(0.5, 0.38, 0.22), 2.0)

func _draw_title_text(text: String, pos: Vector2, color: Color, sc: int) -> void:
	var x := pos.x
	for ch in text:
		if ch == " ":
			x += sc * 6; continue
		if ch == "&":
			draw_rect(Rect2(x, pos.y + sc, sc * 3, sc), color)
			draw_rect(Rect2(x, pos.y + sc * 2, sc, sc * 2), color)
			draw_rect(Rect2(x + sc * 2, pos.y + sc * 2, sc, sc * 2), color)
			x += sc * 5; continue
		_draw_glyph_sc(ch.to_upper(), Vector2(x, pos.y), color, sc)
		x += sc * 6

func _draw_big_text(text: String, pos: Vector2, color: Color, sc: int = 1) -> void:
	var x := pos.x
	for ch in text:
		if ch == " ":
			x += sc * 4; continue
		_draw_glyph_sc(ch.to_upper(), Vector2(x, pos.y), color, sc)
		x += sc * 6

func _draw_glyph_sc(ch: String, pos: Vector2, color: Color, sc: int) -> void:
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
		":":[0,0b00100,0,0b00100,0],"!":[0b00100,0b00100,0b00100,0,0b00100],
		"'":[0b00100,0b00100,0,0,0],".":[0,0,0,0,0b00100],",":[0,0,0,0b00100,0b01000],
	}
	if not glyphs.has(ch):
		return
	var rows: Array = glyphs[ch]
	for row in range(5):
		var bits: int = rows[row]
		for col in range(5):
			if bits & (1 << (4 - col)):
				draw_rect(Rect2(pos.x + col * sc, pos.y + row * sc, sc, sc), color)
