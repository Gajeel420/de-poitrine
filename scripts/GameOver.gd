## Game Over screen with continue countdown
extends Node2D

var continue_timer: float = 9.0
var can_continue: bool = true
var flash_timer: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	continue_timer -= delta
	flash_timer += delta
	if continue_timer <= 0.0:
		can_continue = false
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("p1_attack"):
		if can_continue:
			GameManager.start_game(GameManager.num_players)
	if Input.is_action_just_pressed("ui_back"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color(0.03, 0.03, 0.05))

	# Scattered SPEC-13 logos (they won... for now)
	for i in range(8):
		var px := 60 + i * 70
		var py := 50 + i % 3 * 40
		draw_colored_polygon(
			PackedVector2Array([Vector2(px, py + 12), Vector2(px - 9, py - 4), Vector2(px + 9, py - 4)]),
			Color(0.2, 0.3, 0.9, 0.3)
		)

	# GAME OVER text
	var blink := sin(flash_timer * 4.0) > 0.0
	var go_col := Color(0.95, 0.20, 0.15) if blink else Color(0.75, 0.15, 0.10)
	_draw_text("GAME", Vector2(130, 120), go_col, 8)
	_draw_text("OVER", Vector2(320, 120), go_col, 8)

	# Score
	_draw_text("SCORE", Vector2(200, 210), Color(0.85, 0.80, 0.65), 2)
	_draw_text("%07d" % GameManager.score, Vector2(190, 225), Color(0.95, 0.90, 0.70), 2)

	if GameManager.score >= GameManager.high_score and GameManager.score > 0:
		_draw_text("NEW HI-SCORE!", Vector2(190, 245), Color(1.0, 0.9, 0.2), 2)
	else:
		_draw_text("HI %07d" % GameManager.high_score, Vector2(210, 245), Color(0.60, 0.55, 0.45), 2)

	# Continue prompt
	if can_continue:
		var cnt := int(continue_timer) + 1
		_draw_text("CONTINUE?  %d" % cnt, Vector2(185, 275), Color(0.85, 0.80, 0.65), 2)
		_draw_text("PRESS ENTER TO CONTINUE", Vector2(160, 295), Color(0.65, 0.60, 0.50), 1)
		_draw_text("PRESS ESC FOR MENU", Vector2(210, 305), Color(0.50, 0.46, 0.40), 1)

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
		" ":[0,0,0,0,0],"?":[0b01110,0b10001,0b00110,0,0b00100],
		"!":[0b00100,0b00100,0b00100,0,0b00100],".":[0,0,0,0,0b00100],
		"-":[0,0,0b01110,0,0],"'":[0b00100,0b00100,0,0,0],
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
