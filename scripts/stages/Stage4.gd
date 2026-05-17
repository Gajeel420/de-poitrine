## STAGE 4 — "UTZP" | The TLMEP Television Studio, Montréal
## Enemies: Talk Show Producers | Boss: Broadcast Director
## Perfect run (no damage + all combos synced) unlocks TLMEP Mode
extends StageBase

func _ready() -> void:
	stage_number = 4
	stage_width = 2700.0
	super._ready()
	# Hook damage events to track perfect run
	for p in players:
		p.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_hp: int, _max: int) -> void:
	if new_hp < _max:
		GameManager.stage4_took_damage = true

func _get_lore_text() -> String:
	return "They refused to speak French or English.\nOnly throat noises, whistles, and shrill cries.\nSPEC-13 controls this signal now. Not for long."

func _setup_waves() -> void:
	waves = [
		{
			"scroll_to": 850.0,
			"enemies": [
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 310, "y": 260, "delay": 0.5},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 430, "y": 272, "delay": 1.2},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 520, "y": 264, "delay": 1.8},
			]
		},
		{
			"scroll_to": 1700.0,
			"enemies": [
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 580, "y": 258, "delay": 0.3},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 660, "y": 270, "delay": 0.7},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 740, "y": 280, "delay": 1.1},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 820, "y": 262, "delay": 1.6},
			]
		},
		{
			"scroll_to": 2600.0,
			"enemies": [
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 900, "y": 255, "delay": 0.2},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 970, "y": 268, "delay": 0.5},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 1040, "y": 278, "delay": 0.9},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 1110, "y": 260, "delay": 1.4},
				{"script": "res://scripts/enemies/TalkShowProducer.gd", "x": 1180, "y": 270, "delay": 2.0},
			]
		},
		{
			"scroll_to": 2700.0,
			"is_boss": true,
			"enemies": [
				{"script": "res://scripts/bosses/BroadcastDirector.gd", "x": 1300, "y": 265, "delay": 0.5},
			]
		},
	]

func _on_boss_died(boss: Boss) -> void:
	# Check TLMEP mode unlock
	GameManager.check_tlmep_unlock()
	super._on_boss_died(boss)

func _draw_background() -> void:
	var t := -bg_scroll_1

	# Studio blue lighting
	draw_rect(Rect2(0, 0, 640, 360), Color(0.06, 0.08, 0.18))

	# Studio grid floor (TV studio marks)
	for i in range(10):
		var lx: float = fmod(t * 0.3 + i * 65, 720) - 65
		draw_line(Vector2(lx, 0), Vector2(lx, 220), Color(0.12, 0.15, 0.28, 0.4), 1.0)
	for j in range(5):
		draw_line(Vector2(0, j * 44), Vector2(640, j * 44), Color(0.12, 0.15, 0.28, 0.4), 1.0)

	# Studio cyclorama (curved back wall)
	draw_rect(Rect2(0, 40, 640, 180), Color(0.08, 0.10, 0.20))
	draw_arc(Vector2(320, 220), 340, -PI, 0, 32, Color(0.10, 0.14, 0.26), 8.0)

	# SPEC-13 logo projected on back wall
	var spec_x := 320 + fmod(t * 0.15, 80) - 40
	draw_colored_polygon(
		PackedVector2Array([Vector2(spec_x, 80), Vector2(spec_x - 30, 130), Vector2(spec_x + 30, 130)]),
		Color(0.2, 0.3, 0.9, 0.15)
	)

	# Studio cameras on dollies
	for i in range(3):
		var cam_x: float = fmod(t * 0.6 + i * 200, 840) - 100
		draw_rect(Rect2(cam_x, 165, 20, 14), Color(0.15, 0.15, 0.18))
		draw_rect(Rect2(cam_x + 20, 168, 12, 8), Color(0.12, 0.12, 0.14))
		draw_circle(Vector2(cam_x + 32, 172), 4, Color(0.08, 0.08, 0.10))
		draw_circle(Vector2(cam_x + 32, 172), 2, Color(0.1, 0.25, 0.6))
		# Red recording light
		draw_circle(Vector2(cam_x + 2, 166), 2, Color(0.9, 0.1, 0.1, 0.8))

	# Studio lights overhead (grid)
	for i in range(8):
		var slx: float = fmod(t * 0.4 + i * 82, 780) - 78
		draw_rect(Rect2(slx, 0, 10, 16), Color(0.22, 0.22, 0.26))
		draw_rect(Rect2(slx - 4, 14, 18, 6), Color(0.35, 0.35, 0.40))
		# Light beam
		draw_colored_polygon(
			PackedVector2Array([Vector2(slx + 1, 20), Vector2(slx - 12, 100), Vector2(slx + 22, 100), Vector2(slx + 9, 20)]),
			Color(0.8, 0.85, 1.0, 0.06)
		)

	# Ratings ticker crawl at top
	draw_rect(Rect2(0, 0, 640, 14), Color(0.05, 0.05, 0.15))
	draw_rect(Rect2(0, 12, 640, 2), Color(0.2, 0.4, 0.9))
	# Scrolling ticker text (simulated)
	for i in range(8):
		var ticker_x: float = fmod(t * 2.5 + i * 90, 800) - 90
		draw_rect(Rect2(ticker_x, 2, 70, 8), Color(0.15, 0.15, 0.25, 0.8))

	# TLMEP mode banner (if unlocked)
	if GameManager.tlmep_mode_unlocked:
		draw_rect(Rect2(0, 340, 640, 20), Color(0.8, 0.6, 0.0, 0.9))
