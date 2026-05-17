## STAGE 5 — "YOR ZARAD" | The Pyramide des Ha! Ha!, Saguenay
## Enemies: Speculators | Boss: The Monument Itself
## Environment shifts time signature every 30 seconds
extends StageBase

var time_sig_timer: float = 0.0
var current_time_sig: int = 4
var time_sigs: Array[int] = [4, 7, 5, 3]
var time_sig_index: int = 0
var yield_sign_scroll: Array[float] = []

func _ready() -> void:
	stage_number = 5
	stage_width = 3000.0
	for i in range(20):
		yield_sign_scroll.append(randf() * 640)
	super._ready()

func _get_lore_text() -> String:
	return "3,000 yield signs. Each one replaced by a SPEC-13 logo.\nThe environment itself is out of time.\nRestore the signal."

func _setup_waves() -> void:
	waves = [
		{
			"scroll_to": 1000.0,
			"enemies": [
				{"script": "res://scripts/enemies/Speculator.gd", "x": 350, "y": 262, "delay": 0.8},
				{"script": "res://scripts/enemies/Speculator.gd", "x": 460, "y": 275, "delay": 1.8},
			]
		},
		{
			"scroll_to": 2000.0,
			"enemies": [
				{"script": "res://scripts/enemies/Speculator.gd", "x": 600, "y": 260, "delay": 0.5},
				{"script": "res://scripts/enemies/Speculator.gd", "x": 700, "y": 272, "delay": 1.2},
				{"script": "res://scripts/enemies/Speculator.gd", "x": 800, "y": 265, "delay": 2.0},
			]
		},
		{
			"scroll_to": 2900.0,
			"enemies": [
				{"script": "res://scripts/enemies/Speculator.gd", "x": 900, "y": 258, "delay": 0.4},
				{"script": "res://scripts/enemies/Speculator.gd", "x": 1000, "y": 270, "delay": 1.0},
				{"script": "res://scripts/enemies/Speculator.gd", "x": 1100, "y": 262, "delay": 1.8},
				{"script": "res://scripts/enemies/Speculator.gd", "x": 1200, "y": 278, "delay": 2.6},
			]
		},
		{
			"scroll_to": 3000.0,
			"is_boss": true,
			"enemies": [
				{"script": "res://scripts/bosses/TheMonument.gd", "x": 1450, "y": 268, "delay": 1.0},
			]
		},
	]

func _process(delta: float) -> void:
	super._process(delta)
	# Shift time signature every 30s
	time_sig_timer += delta
	if time_sig_timer >= 30.0:
		time_sig_timer = 0.0
		time_sig_index = (time_sig_index + 1) % time_sigs.size()
		current_time_sig = time_sigs[time_sig_index]
		GameManager.trigger_screen_shake(3.0, 0.25)
		# Apply to enemies
		for e in get_tree().get_nodes_in_group("enemies"):
			if e.has_method("enter_odd_meter"):
				e.enter_odd_meter(2.0)  # brief stumble on time sig change

func _draw_background() -> void:
	var t := -bg_scroll_2

	# Rocky Saguenay landscape — bluffs, river below
	draw_rect(Rect2(0, 0, 640, 360), Color(0.10, 0.12, 0.10))

	# Sky — overcast, grey
	draw_rect(Rect2(0, 0, 640, 160), Color(0.48, 0.48, 0.52))
	# Cloud masses
	for i in range(6):
		var cx := fmod(t * 0.15 + i * 110, 740) - 50
		var cy2 := 60 + i % 3 * 20
		for j in range(24):
			var a := j * TAU / 24.0
			var p1 := Vector2(cx + cos(a) * 80, cy2 + sin(a) * 22)
			var p2 := Vector2(cx + cos(a + TAU/24.0) * 80, cy2 + sin(a + TAU/24.0) * 22)
			draw_line(p1, p2, Color(0.55, 0.55, 0.60), 1.0)

	# Bluffs in distance
	for i in range(5):
		var bx := fmod(t * 0.25 + i * 130, 790) - 100
		draw_colored_polygon(
			PackedVector2Array([Vector2(bx, 165), Vector2(bx + 30, 100), Vector2(bx + 100, 90), Vector2(bx + 140, 165)]),
			Color(0.25, 0.28, 0.22)
		)

	# The Pyramide des Ha! Ha! silhouette (in background)
	var pyr_x := 300 + fmod(t * 0.3, 400) - 100
	draw_colored_polygon(
		PackedVector2Array([Vector2(pyr_x, 165), Vector2(pyr_x + 60, 90), Vector2(pyr_x + 120, 165)]),
		Color(0.55, 0.45, 0.25)
	)
	# Corrupted SPEC-13 logos on pyramid (inverted triangles)
	for i in range(4):
		var sx := pyr_x + 20 + i * 22
		var sy := 140 + i % 2 * 12
		draw_colored_polygon(
			PackedVector2Array([Vector2(sx, sy + 8), Vector2(sx - 7, sy), Vector2(sx + 7, sy)]),
			Color(0.2, 0.3, 0.9, 0.6)
		)

	# Scattered yield signs (recovering / corrupted, floating in the field)
	for i in range(12):
		var sx := fmod(t * 0.8 + i * 55, 720) - 55
		var sy := 195 + i % 4 * 10
		var is_corrupt := i % 3 != 0
		if is_corrupt:
			draw_colored_polygon(
				PackedVector2Array([Vector2(sx, sy + 10), Vector2(sx - 8, sy - 4), Vector2(sx + 8, sy - 4)]),
				Color(0.2, 0.3, 0.8, 0.5)
			)
		else:
			draw_colored_polygon(
				PackedVector2Array([Vector2(sx, sy - 10), Vector2(sx - 8, sy + 4), Vector2(sx + 8, sy + 4)]),
				Color(0.9, 0.65, 0.1, 0.6)
			)

	# Time signature indicator (subtle, bottom-right)
	var ts_text_col := Color(0.9, 0.85, 0.6, 0.5)
	for beat in range(current_time_sig):
		var bx := 590 + beat * 8 if beat < 5 else 590 + (beat - 5) * 8
		var by := 340 if beat < 5 else 350
		var beat_on := fmod(time_sig_timer, 0.5) < 0.25 and beat == int(fmod(time_sig_timer, float(current_time_sig)))
		draw_rect(Rect2(bx, by, 5, 6), Color(0.9, 0.85, 0.6, 0.8 if beat_on else 0.3))

