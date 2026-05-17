## STAGE 1 — "SHERPA" | The Chicoutimi Tavern
## Enemies: Overexposure Agents | Boss: The Venue Owner
extends StageBase

func _ready() -> void:
	stage_number = 1
	stage_width = 2800.0
	super._ready()

func _get_lore_text() -> String:
	return "Khn picks up a sardine from behind the bar.\nIt is from the old days.\nHe nods at Klek. The fight begins."

func _setup_waves() -> void:
	waves = [
		# Wave 1 — three agents blocking the entrance
		{
			"scroll_to": 900.0,
			"enemies": [
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 320, "y": 258, "delay": 0.5},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 420, "y": 272, "delay": 1.2},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 500, "y": 265, "delay": 2.0},
			]
		},
		# Wave 2 — five agents swarming from both sides
		{
			"scroll_to": 1900.0,
			"enemies": [
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 580, "y": 260, "delay": 0.3},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 650, "y": 275, "delay": 0.6},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 720, "y": 262, "delay": 0.9},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 790, "y": 280, "delay": 1.5},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 860, "y": 265, "delay": 2.2},
			]
		},
		# Wave 3 — big wave before boss
		{
			"scroll_to": 2600.0,
			"enemies": [
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 900, "y": 255, "delay": 0.2},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 970, "y": 270, "delay": 0.5},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 1040, "y": 282, "delay": 0.8},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 1110, "y": 260, "delay": 1.2},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 1180, "y": 275, "delay": 1.8},
				{"script": "res://scripts/enemies/OverexposureAgent.gd", "x": 1250, "y": 265, "delay": 2.4},
			]
		},
		# Boss wave — The Venue Owner
		{
			"scroll_to": 2800.0,
			"is_boss": true,
			"enemies": [
				{"script": "res://scripts/bosses/VenueOwner.gd", "x": 1500, "y": 268, "delay": 0.5},
			]
		},
	]

func _draw_background() -> void:
	# Tavern interior — wood paneling, dim lighting, bottles
	var t := -bg_scroll_1

	# Dark tavern ceiling/back wall
	draw_rect(Rect2(0, 0, 640, 220), Color(0.12, 0.08, 0.06))

	# Back wall wood panels
	for i in range(9):
		var px: float = fmod(t * 0.3 + i * 72, 720) - 72
		draw_rect(Rect2(px, 20, 68, 200), Color(0.18, 0.11, 0.07))
		draw_line(Vector2(px, 20), Vector2(px, 220), Color(0.10, 0.06, 0.04), 2)
		draw_line(Vector2(px + 68, 20), Vector2(px + 68, 220), Color(0.10, 0.06, 0.04), 2)

	# Horizontal rail
	draw_rect(Rect2(0, 150, 640, 6), Color(0.22, 0.14, 0.09))

	# Shelf with bottles
	draw_rect(Rect2(0, 140, 640, 10), Color(0.25, 0.16, 0.10))
	for i in range(18):
		var bx: float = fmod(t * 0.4 + i * 36, 720) - 36
		var bh := 24 + (i % 3) * 8
		var bottle_col := [
			Color(0.15, 0.35, 0.15),
			Color(0.45, 0.30, 0.10),
			Color(0.12, 0.12, 0.35),
		][i % 3]
		draw_rect(Rect2(bx + 2, 140 - bh, 10, bh), bottle_col)
		draw_rect(Rect2(bx + 4, 140 - bh - 6, 6, 6), bottle_col)
		draw_circle(Vector2(bx + 7, 140 - bh - 8), 3, Color(0.65, 0.65, 0.65, 0.5))

	# Bar counter (foreground)
	draw_rect(Rect2(0, 200, 640, 30), Color(0.28, 0.18, 0.10))
	draw_rect(Rect2(0, 198, 640, 4), Color(0.35, 0.24, 0.14))

	# Dim hanging lamp circles
	for i in range(5):
		var lx: float = fmod(t * 0.5 + i * 130, 780) - 130
		draw_circle(Vector2(lx, 30), 12, Color(0.55, 0.48, 0.22))
		draw_circle(Vector2(lx, 30), 8, Color(0.9, 0.8, 0.5, 0.7))
		draw_line(Vector2(lx, 0), Vector2(lx, 20), Color(0.35, 0.28, 0.18), 2)

	# Sardine can easter egg (near start)
	if -t < 60 and -t > -30:
		draw_rect(Rect2(50 + t, 196, 22, 8), Color(0.55, 0.55, 0.55))
		draw_rect(Rect2(52 + t, 198, 18, 4), Color(0.72, 0.52, 0.28))
