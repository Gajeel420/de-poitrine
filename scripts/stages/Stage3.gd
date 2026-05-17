## STAGE 3 — "SARNIEZZ" | The Montreal Jazz Festival Grounds
## Enemies: Festival Infiltrators | Boss: Impersonator Prime
extends StageBase

func _ready() -> void:
	stage_number = 3
	stage_width = 2900.0
	super._ready()

func _get_lore_text() -> String:
	return "SPEC-13 hired imposters in cheap polka-dot suits.\nThey cannot copy what they cannot understand."

func _setup_waves() -> void:
	waves = [
		{
			"scroll_to": 900.0,
			"enemies": [
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 300, "y": 260, "delay": 0.4},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 400, "y": 275, "delay": 1.0},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 480, "y": 262, "delay": 1.6},
			]
		},
		{
			"scroll_to": 1900.0,
			"enemies": [
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 560, "y": 257, "delay": 0.3},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 630, "y": 272, "delay": 0.6},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 700, "y": 260, "delay": 0.9},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 770, "y": 280, "delay": 1.4},
			]
		},
		{
			"scroll_to": 2800.0,
			"enemies": [
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 850, "y": 255, "delay": 0.2},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 920, "y": 268, "delay": 0.5},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 990, "y": 278, "delay": 0.8},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 1060, "y": 262, "delay": 1.2},
				{"script": "res://scripts/enemies/FestivalInfiltrator.gd", "x": 1130, "y": 270, "delay": 1.7},
			]
		},
		{
			"scroll_to": 2900.0,
			"is_boss": true,
			"enemies": [
				{"script": "res://scripts/bosses/ImpersonatorPrime.gd", "x": 1350, "y": 265, "delay": 0.5},
			]
		},
	]

func _draw_background() -> void:
	var t := -bg_scroll_2

	# Evening sky — Montreal dusk
	draw_rect(Rect2(0, 0, 640, 220), Color(0.12, 0.08, 0.18))
	# Gradient strips
	for i in range(5):
		draw_rect(Rect2(0, i * 44, 640, 44),
			Color(0.18 - i * 0.02, 0.10 + i * 0.02, 0.25 - i * 0.02, 0.5))

	# Crowd silhouettes (festival audience)
	for i in range(30):
		var cx := fmod(t * 0.3 + i * 22, 700) - 22
		var ch := 16 + i % 5 * 4
		draw_rect(Rect2(cx, 185 - ch, 8, ch), Color(0.06, 0.04, 0.08))
		draw_circle(Vector2(cx + 4, 186 - ch), 5, Color(0.06, 0.04, 0.08))

	# Festival lights / lanterns
	for i in range(10):
		var lx := fmod(t * 0.5 + i * 66, 780) - 66
		var lh := 30 + i % 3 * 20
		draw_line(Vector2(lx, 0), Vector2(lx, lh), Color(0.25, 0.20, 0.14), 1.5)
		var light_col := [Color(0.9, 0.3, 0.3), Color(0.3, 0.7, 0.9), Color(0.9, 0.8, 0.2)][i % 3]
		draw_circle(Vector2(lx, lh), 8, light_col)
		draw_circle(Vector2(lx, lh), 4, Color(1.0, 1.0, 1.0, 0.6))
		# Light cone
		draw_colored_polygon(
			PackedVector2Array([Vector2(lx - 2, lh), Vector2(lx - 20, lh + 60), Vector2(lx + 20, lh + 60), Vector2(lx + 2, lh)]),
			Color(light_col.r, light_col.g, light_col.b, 0.08)
		)

	# Stage / tent structure
	draw_rect(Rect2(fmod(t * 0.4, 900) + 200, 140, 240, 60), Color(0.18, 0.14, 0.22))
	draw_rect(Rect2(fmod(t * 0.4, 900) + 195, 138, 250, 5), Color(0.5, 0.3, 0.6))

	# Confetti dots
	for i in range(20):
		var cfx := fmod(t * (1.5 + i * 0.1) + i * 32, 680) - 20
		var cfy := 100 + i * 6 % 120
		draw_circle(Vector2(cfx, cfy), 2, Color(float(i % 3 == 0), float(i % 3 == 1), float(i % 3 == 2), 0.6))
