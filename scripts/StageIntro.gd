## Stage title card — fades in with stage name, location, lore text then fades out.
extends Control

var stage_name: String = ""
var location_text: String = ""
var lore_text: String = ""
var alpha: float = 0.0
var fade_in: bool = true
var display_timer: float = 0.0
const FADE_SPEED: float = 2.0
const DISPLAY_TIME: float = 2.0

func show_intro(s_name: String, s_location: String, s_lore: String) -> void:
	stage_name = s_name
	location_text = s_location
	lore_text = s_lore
	set_process(true)
	queue_redraw()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)

func _process(delta: float) -> void:
	if fade_in:
		alpha += delta * FADE_SPEED
		if alpha >= 1.0:
			alpha = 1.0
			fade_in = false
			display_timer = DISPLAY_TIME
	else:
		display_timer -= delta
		if display_timer <= 0.0:
			alpha -= delta * FADE_SPEED
			if alpha <= 0.0:
				alpha = 0.0
				set_process(false)
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	if alpha <= 0.001:
		return

	# Black overlay
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, alpha * 0.85))

	# Stage number pill (top-left corner accent)
	var pill_col := Color(0.85, 0.75, 0.55, alpha)
	draw_rect(Rect2(60, 120, 3, 60), pill_col)

	# Stage name (large, centered)
	var name_col := Color(0.95, 0.90, 0.70, alpha)
	_draw_big_text(stage_name, Vector2(80, 125), name_col, 3)

	# Location
	var loc_col := Color(0.65, 0.60, 0.50, alpha * 0.9)
	_draw_big_text(location_text, Vector2(80, 150), loc_col, 1)

	# Separator line
	draw_line(Vector2(80, 165), Vector2(560, 165), Color(0.5, 0.45, 0.35, alpha * 0.6), 1.0)

	# Lore text
	var lore_col := Color(0.80, 0.75, 0.65, alpha * 0.85)
	var lines := lore_text.split("\n")
	for i in range(lines.size()):
		_draw_big_text(lines[i], Vector2(80, 175 + i * 14), lore_col, 1)

	# Yield sign motif (bottom right)
	draw_colored_polygon(
		PackedVector2Array([Vector2(560, 240), Vector2(535, 280), Vector2(585, 280)]),
		Color(0.9, 0.65, 0.1, alpha * 0.4)
	)

func _draw_big_text(text: String, pos: Vector2, color: Color, scale: int = 1) -> void:
	# Use HUDDrawer's glyph system via manually scaling
	var x := pos.x
	for ch in text:
		_draw_glyph_scaled(ch.to_upper(), Vector2(x, pos.y), color, scale)
		x += (5 + 1) * scale

func _draw_glyph_scaled(ch: String, pos: Vector2, color: Color, sc: int) -> void:
	# Duplicated mini glyph renderer (for independence from HUD)
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
		" ":[0,0,0,0,0],"-":[0,0,0b01110,0,0],"!":[0b00100,0b00100,0b00100,0,0b00100],
		",":[0,0,0,0b00100,0b01000],".":[0,0,0,0,0b00100],"'":[0b00100,0b00100,0,0,0],
	}
	if not glyphs.has(ch):
		return
	var rows: Array = glyphs[ch]
	for row in range(5):
		var bits: int = rows[row]
		for col in range(5):
			if bits & (1 << (4 - col)):
				draw_rect(Rect2(pos.x + col * sc, pos.y + row * sc, sc, sc), color)
