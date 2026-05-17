## STAGE 6 — "ANGOR" | The SPEC-13 Pyramid Tower, Top Floor
## Enemies: Hollow Executives | Boss: Fabio Spek-Trois
## Atmospheric, slow, dark. The last enemies are not evil — they are empty.
extends StageBase

func _ready() -> void:
	stage_number = 6
	stage_width = 2600.0
	scroll_speed = 28.0  # slow, atmospheric
	super._ready()

func _get_lore_text() -> String:
	return "They are not evil. They are empty.\nThey are the warning.\nThe signal ends here — or begins again."

func _setup_waves() -> void:
	HollowExecutive.sync_clock = 0.0  # reset shared sync

	waves = [
		{
			"scroll_to": 900.0,
			"enemies": [
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 320, "y": 258, "delay": 0.0, "sync_offset": 0.0},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 400, "y": 272, "delay": 0.0, "sync_offset": 0.05},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 480, "y": 260, "delay": 0.0, "sync_offset": 0.10},
			]
		},
		{
			"scroll_to": 1800.0,
			"enemies": [
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 570, "y": 255, "delay": 0.0, "sync_offset": 0.00},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 640, "y": 268, "delay": 0.0, "sync_offset": 0.04},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 710, "y": 278, "delay": 0.0, "sync_offset": 0.08},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 780, "y": 263, "delay": 0.0, "sync_offset": 0.12},
			]
		},
		{
			"scroll_to": 2500.0,
			"enemies": [
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 870, "y": 252, "delay": 0.0, "sync_offset": 0.00},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 940, "y": 265, "delay": 0.0, "sync_offset": 0.03},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 1010, "y": 275, "delay": 0.0, "sync_offset": 0.06},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 1080, "y": 258, "delay": 0.0, "sync_offset": 0.09},
				{"script": "res://scripts/enemies/HollowExecutive.gd", "x": 1150, "y": 270, "delay": 0.0, "sync_offset": 0.12},
			]
		},
		{
			"scroll_to": 2600.0,
			"is_boss": true,
			"enemies": [
				{"script": "res://scripts/bosses/FabioSpekTrois.gd", "x": 1400, "y": 268, "delay": 1.5},
			]
		},
	]

func _on_boss_died(boss: Boss) -> void:
	# Check vinyl unlocks
	if GameManager.score > 50000:
		GameManager.hotdog_vinyl_unlocked = true
	if GameManager.num_players == 2:
		GameManager.sardine_vinyl_unlocked = true
	super._on_boss_died(boss)

func _draw_background() -> void:
	var t := -bg_scroll_1

	# Almost-black corporate tower interior
	draw_rect(Rect2(0, 0, 640, 360), Color(0.04, 0.04, 0.06))

	# Floor-to-ceiling glass panels (pyramid facets)
	for i in range(8):
		var px: float = fmod(t * 0.4 + i * 82, 760) - 80
		draw_line(Vector2(px, 0), Vector2(px + 40, 220), Color(0.10, 0.12, 0.18, 0.4), 1.0)
		draw_line(Vector2(px + 82, 0), Vector2(px + 42, 220), Color(0.10, 0.12, 0.18, 0.4), 1.0)
		# Faint reflection
		draw_rect(Rect2(px + 1, 20, 38, 180), Color(0.08, 0.10, 0.16, 0.15))

	# SPEC-13 logos (inverted triangles) on every wall panel
	for i in range(12):
		var sx: float = fmod(t * 0.4 + i * 55, 720) - 55
		var sy := 40 + i % 4 * 40
		var logo_alpha := 0.25 + sin(Time.get_ticks_msec() * 0.001 + i * 0.5) * 0.1
		draw_colored_polygon(
			PackedVector2Array([Vector2(sx, sy + 14), Vector2(sx - 10, sy - 5), Vector2(sx + 10, sy - 5)]),
			Color(0.25, 0.40, 0.90, logo_alpha)
		)

	# Ambient blue-purple light shafts (descending from pyramid apex)
	for i in range(5):
		var lx: float = fmod(t * 0.2 + i * 130, 780) - 78
		draw_colored_polygon(
			PackedVector2Array([Vector2(lx - 2, 0), Vector2(lx + 2, 0), Vector2(lx + 30, 220), Vector2(lx - 30, 220)]),
			Color(0.15, 0.20, 0.55, 0.06)
		)

	# Saguenay city lights visible through glass (floor 6 view)
	for i in range(30):
		var bx: float = fmod(t * 0.1 + i * 22, 680) - 22
		var by_val := 150 + i % 5 * 14
		draw_rect(Rect2(bx, by_val, 4, 8), Color(0.9, 0.85, 0.6, 0.15 + float(i % 3) * 0.06))

	# The Pyramide des Ha! Ha! visible in extreme distance through window
	var pdist := 260 + fmod(t * 0.05, 100) - 30
	draw_colored_polygon(
		PackedVector2Array([Vector2(pdist, 190), Vector2(pdist + 14, 170), Vector2(pdist + 28, 190)]),
		Color(0.92, 0.62, 0.10, 0.25)
	)
	# Restored yield signs glowing on the Pyramide
	for i in range(4):
		var yx := pdist + 4 + i * 6
		draw_colored_polygon(
			PackedVector2Array([Vector2(yx, 186), Vector2(yx - 3, 192), Vector2(yx + 3, 192)]),
			Color(0.95, 0.65, 0.1, 0.4)
		)

	# Oxygen — the air up here feels thin, processed
	draw_rect(Rect2(0, 0, 640, 360), Color(0.04, 0.04, 0.08, 0.12))
