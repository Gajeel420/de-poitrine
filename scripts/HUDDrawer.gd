## Draws the HUD visuals (child of HUD CanvasLayer, rendered on top of game)
extends Node2D

var hud: Node  # Set by HUD._ready()

func _draw() -> void:
	if not hud:
		return
	_draw_player_bars()
	_draw_boss_bar()
	_draw_score()
	_draw_stage_name()

func _draw_player_bars() -> void:
	# --- PLAYER 1 (top-left) ---
	var p1_col := Color(0.95, 0.20, 0.20)
	var p1_sp_col := Color(0.30, 0.65, 1.00)
	_draw_bar(Vector2(8, 8), 120, 8, hud.p1_hp / hud.p1_hp_max, p1_col, "KHN")
	_draw_bar(Vector2(8, 20), 120, 4, hud.p1_special / hud.p1_special_max, p1_sp_col, "")

	if hud.num_players >= 2:
		# --- PLAYER 2 (top-right) ---
		var p2_col := Color(0.95, 0.60, 0.10)
		var p2_sp_col := Color(1.00, 0.50, 0.10)
		_draw_bar(Vector2(512, 8), 120, 8, hud.p2_hp / hud.p2_hp_max, p2_col, "KLEK")
		_draw_bar(Vector2(512, 20), 120, 4, hud.p2_special / hud.p2_special_max, p2_sp_col, "")

func _draw_bar(pos: Vector2, width: float, height: float, ratio: float,
		fill_col: Color, label: String) -> void:
	# Background
	draw_rect(Rect2(pos.x, pos.y, width, height), Color(0.10, 0.10, 0.12))
	# Fill
	draw_rect(Rect2(pos.x, pos.y, width * clamp(ratio, 0.0, 1.0), height), fill_col)
	# Border
	draw_rect(Rect2(pos.x - 1, pos.y - 1, width + 2, height + 2), Color(0.5, 0.5, 0.5, 0.6), false)
	# Label (simulated with small colored blocks)
	if not label.is_empty():
		_draw_pixel_text(label, pos + Vector2(0, -8), Color(0.85, 0.85, 0.85))

func _draw_boss_bar() -> void:
	if not hud.boss_visible:
		return
	var bw := 280.0
	var bx := (640 - bw) / 2.0
	var by := 340.0
	# Background
	draw_rect(Rect2(bx - 2, by - 2, bw + 4, 12), Color(0.10, 0.10, 0.12))
	# Fill — red to orange as damage accumulates
	var ratio = hud.boss_hp / hud.boss_hp_max
	var bar_col := Color(0.9 + (1.0 - ratio) * 0.1, 0.15 + (1.0 - ratio) * 0.4, 0.15)
	draw_rect(Rect2(bx, by, bw * clamp(ratio, 0.0, 1.0), 8), bar_col)
	draw_rect(Rect2(bx - 1, by - 1, bw + 2, 10), Color(0.6, 0.5, 0.4, 0.7), false)
	# Boss name
	_draw_pixel_text(hud.boss_name_text, Vector2(bx, by - 12), Color(0.9, 0.85, 0.7))

func _draw_score() -> void:
	var score_str: String = "SCORE: %07d" % hud.displayed_score
	_draw_pixel_text(score_str, Vector2(240, 8), Color(0.95, 0.90, 0.70))

func _draw_stage_name() -> void:
	if hud.stage_name_timer <= 0.0:
		return
	var alpha = min(hud.stage_name_timer, 1.0)
	var stage_name: String = GameManager.STAGE_NAMES[hud.stage_number]
	_draw_pixel_text(stage_name, Vector2(240, 26), Color(0.9, 0.85, 0.6, alpha))

# Pixel text renderer — draws colored bars for each character (lo-fi look)
# Uses a tiny glyph map: each letter = 3x5 pixel pattern
func _draw_pixel_text(text: String, pos: Vector2, color: Color) -> void:
	var x := pos.x
	for ch in text:
		_draw_glyph(ch, Vector2(x, pos.y), color)
		x += 5

func _draw_glyph(ch: String, pos: Vector2, color: Color) -> void:
	var glyphs: Dictionary = {
		"A": [0b01110,0b10001,0b11111,0b10001,0b10001],
		"B": [0b11110,0b10001,0b11110,0b10001,0b11110],
		"C": [0b01111,0b10000,0b10000,0b10000,0b01111],
		"D": [0b11110,0b10001,0b10001,0b10001,0b11110],
		"E": [0b11111,0b10000,0b11110,0b10000,0b11111],
		"F": [0b11111,0b10000,0b11110,0b10000,0b10000],
		"G": [0b01111,0b10000,0b10011,0b10001,0b01111],
		"H": [0b10001,0b10001,0b11111,0b10001,0b10001],
		"I": [0b11111,0b00100,0b00100,0b00100,0b11111],
		"J": [0b11111,0b00010,0b00010,0b10010,0b01100],
		"K": [0b10001,0b10010,0b11100,0b10010,0b10001],
		"L": [0b10000,0b10000,0b10000,0b10000,0b11111],
		"M": [0b10001,0b11011,0b10101,0b10001,0b10001],
		"N": [0b10001,0b11001,0b10101,0b10011,0b10001],
		"O": [0b01110,0b10001,0b10001,0b10001,0b01110],
		"P": [0b11110,0b10001,0b11110,0b10000,0b10000],
		"Q": [0b01110,0b10001,0b10101,0b10010,0b01101],
		"R": [0b11110,0b10001,0b11110,0b10010,0b10001],
		"S": [0b01111,0b10000,0b01110,0b00001,0b11110],
		"T": [0b11111,0b00100,0b00100,0b00100,0b00100],
		"U": [0b10001,0b10001,0b10001,0b10001,0b01110],
		"V": [0b10001,0b10001,0b10001,0b01010,0b00100],
		"W": [0b10001,0b10001,0b10101,0b11011,0b10001],
		"X": [0b10001,0b01010,0b00100,0b01010,0b10001],
		"Y": [0b10001,0b01010,0b00100,0b00100,0b00100],
		"Z": [0b11111,0b00010,0b00100,0b01000,0b11111],
		"0": [0b01110,0b10011,0b10101,0b11001,0b01110],
		"1": [0b00110,0b01010,0b00100,0b00100,0b01110],
		"2": [0b01110,0b10001,0b00110,0b01000,0b11111],
		"3": [0b11110,0b00001,0b01110,0b00001,0b11110],
		"4": [0b00110,0b01010,0b10010,0b11111,0b00010],
		"5": [0b11111,0b10000,0b11110,0b00001,0b11110],
		"6": [0b01110,0b10000,0b11110,0b10001,0b01110],
		"7": [0b11111,0b00001,0b00010,0b00100,0b00100],
		"8": [0b01110,0b10001,0b01110,0b10001,0b01110],
		"9": [0b01110,0b10001,0b01111,0b00001,0b01110],
		":": [0b00000,0b00100,0b00000,0b00100,0b00000],
		"-": [0b00000,0b00000,0b01110,0b00000,0b00000],
		" ": [0b00000,0b00000,0b00000,0b00000,0b00000],
		"!": [0b00100,0b00100,0b00100,0b00000,0b00100],
		".": [0b00000,0b00000,0b00000,0b00000,0b00100],
		"'": [0b00100,0b00100,0b00000,0b00000,0b00000],
	}
	var uch := ch.to_upper()
	if not glyphs.has(uch):
		return
	var rows: Array = glyphs[uch]
	for row in range(5):
		var bits: int = rows[row]
		for col in range(5):
			if bits & (1 << (4 - col)):
				draw_rect(Rect2(pos.x + col, pos.y + row, 1, 1), color)
