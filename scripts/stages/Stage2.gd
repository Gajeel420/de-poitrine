## STAGE 2 — "MATA ZYKLEK" | The Highway out of Saguenay
## Enemies: Streaming Drones | Boss: The Curator Bot
extends StageBase

func _ready() -> void:
	stage_number = 2
	stage_width = 3200.0
	scroll_speed = 60.0  # faster — high-speed chase
	super._ready()

func _get_lore_text() -> String:
	return "The highway stretches out.\nIdentical drones on identical mopeds.\nThe algorithm has no surprises."

func _setup_waves() -> void:
	# Streaming Drones come in formation
	waves = [
		{
			"scroll_to": 1000.0,
			"enemies": [
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 350, "y": 258, "delay": 0.3, "formation_offset": Vector2(0, -20)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 380, "y": 270, "delay": 0.3, "formation_offset": Vector2(30, 0)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 350, "y": 282, "delay": 0.3, "formation_offset": Vector2(0, 20)},
			]
		},
		{
			"scroll_to": 2000.0,
			"enemies": [
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 600, "y": 252, "delay": 0.2, "formation_offset": Vector2(-30, -15)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 640, "y": 265, "delay": 0.2, "formation_offset": Vector2(0, 0)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 680, "y": 278, "delay": 0.2, "formation_offset": Vector2(30, 15)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 720, "y": 260, "delay": 0.5, "formation_offset": Vector2(60, 0)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 760, "y": 273, "delay": 0.8, "formation_offset": Vector2(90, 0)},
			]
		},
		{
			"scroll_to": 3000.0,
			"enemies": [
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 900, "y": 255, "delay": 0.1, "formation_offset": Vector2(-40, -20)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 940, "y": 265, "delay": 0.1, "formation_offset": Vector2(-20, 0)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 980, "y": 275, "delay": 0.1, "formation_offset": Vector2(0, 20)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 1020, "y": 260, "delay": 0.3, "formation_offset": Vector2(20, -10)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 1060, "y": 270, "delay": 0.5, "formation_offset": Vector2(40, 10)},
				{"script": "res://scripts/enemies/StreamingDrone.gd", "x": 1100, "y": 258, "delay": 0.7, "formation_offset": Vector2(60, -20)},
			]
		},
		{
			"scroll_to": 3200.0,
			"is_boss": true,
			"enemies": [
				{"script": "res://scripts/bosses/CuratorBot.gd", "x": 1400, "y": 265, "delay": 0.5},
			]
		},
	]

func _draw_background() -> void:
	var t := -bg_scroll_2

	# Night sky
	draw_rect(Rect2(0, 0, 640, 220), Color(0.04, 0.04, 0.08))

	# Stars
	var star_seed := 42
	for i in range(40):
		var sx = fmod(float(i * 73 + star_seed) * 0.137 * 640 + t * 0.1, 700) - 30
		var sy := float(i * 31 % 180) + 10
		draw_circle(Vector2(sx, sy), 0.8 + float(i % 3) * 0.4, Color(1.0, 1.0, 1.0, 0.5 + float(i % 5) * 0.1))

	# Distant treeline silhouette (Saguenay boreal forest)
	for i in range(25):
		var tx = fmod(t * 0.2 + i * 28, 720) - 28
		var th := 30 + (i % 4) * 12
		draw_colored_polygon(
			PackedVector2Array([Vector2(tx, 190), Vector2(tx + 14, 190 - th), Vector2(tx + 28, 190)]),
			Color(0.06, 0.10, 0.07)
		)

	# Asphalt road (center)
	draw_rect(Rect2(0, 190, 640, 50), Color(0.22, 0.22, 0.24))

	# Yellow center dividing line (dashed)
	for i in range(12):
		var lx = fmod(t * 1.5 + i * 60, 780) - 60
		draw_rect(Rect2(lx, 212, 38, 4), Color(0.9, 0.8, 0.1))

	# Road shoulder lines
	draw_rect(Rect2(0, 192, 640, 3), Color(0.85, 0.85, 0.75))
	draw_rect(Rect2(0, 235, 640, 3), Color(0.85, 0.85, 0.75))

	# Speed blur streaks
	for i in range(8):
		var bx = fmod(t * 3.0 + i * 82, 800) - 80
		var by := 200 + i * 4
		draw_line(Vector2(bx, by), Vector2(bx - 40, by), Color(0.8, 0.9, 1.0, 0.12), 1.5)

	# Saguenay valley cliff in distance
	draw_rect(Rect2(0, 145, 640, 50), Color(0.10, 0.12, 0.15))
	for i in range(6):
		var cx = fmod(t * 0.15 + i * 110, 740) - 50
		draw_rect(Rect2(cx, 100 + i * 5, 90, 55), Color(0.08, 0.10, 0.12))
