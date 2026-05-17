## STAGE 2 BOSS — The Curator Bot
## Chrome humanoid. Only damageable when players attack in the same time signature.
## Current time sig displayed on its chest; KLEK's ODD METER is essential.
class_name CuratorBot
extends Boss

var current_meter: int = 4   # beats per measure (4/4, 7/8, 5/4...)
var beat_clock: float = 0.0
var beat_period: float = 0.5  # seconds per beat
var vulnerable_window: float = 0.0
var vulnerability_open: bool = false
var metadata_projectiles: Array[Dictionary] = []
var proj_timer: float = 0.0
const METERS: Array[int] = [4, 7, 5, 3, 6]
var meter_index: int = 0
var invulnerable_flash: float = 0.0

func _ready() -> void:
	max_health = 400
	move_speed = 50.0
	attack_damage = 16
	attack_range = 40.0
	attack_cooldown = 2.5
	score_value = 1200
	phase_thresholds = [0.55]
	enemy_color = Color(0.7, 0.75, 0.8)  # chrome
	super._ready()

func _on_phase_enter(phase: int) -> void:
	# Phase 2: faster meter changes, more projectiles
	beat_period = 0.35
	proj_timer = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	beat_clock += delta
	proj_timer -= delta
	invulnerable_flash -= delta

	# Advance beat
	if beat_clock >= beat_period * current_meter:
		beat_clock = 0.0
		_change_meter()

	# Vulnerability window opens on beat 1 of each measure
	var beat_in_measure = fmod(beat_clock, beat_period)
	vulnerability_open = beat_in_measure < 0.12  # 120ms window on the beat

	if proj_timer <= 0.0:
		_fire_metadata_burst()
		proj_timer = 2.0 if current_phase == 1 else 1.2

	_update_projectiles(delta)

func _change_meter() -> void:
	meter_index = (meter_index + 1) % METERS.size()
	current_meter = METERS[meter_index]
	GameManager.trigger_screen_shake(2.0, 0.15)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if not vulnerability_open:
		# Invulnerable — deflect with flash
		invulnerable_flash = 0.3
		GameManager.trigger_screen_shake(1.5, 0.08)
		return
	super.take_damage(amount, knockback)

func enter_odd_meter(duration: float) -> void:
	# ODD METER forces vulnerability open for its entire duration
	vulnerability_open = true
	super.enter_odd_meter(duration)
	await get_tree().create_timer(duration).timeout
	vulnerability_open = false

func _fire_metadata_burst() -> void:
	for i in range(4):
		var angle := i * TAU / 4.0 + randf() * 0.4
		metadata_projectiles.append({
			"pos": Vector2(global_position),
			"vel": Vector2(cos(angle), sin(angle) * 0.5) * 130.0,
			"life": 2.5,
			"hit_set": [],
			"tag": ["playlist", "algorithm", "reach", "curation"][i % 4],
		})

func _update_projectiles(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(metadata_projectiles.size()):
		var p: Dictionary = metadata_projectiles[i]
		p["pos"] += p["vel"] * delta
		p["life"] -= delta
		if p["life"] <= 0.0:
			expired.append(i)
			continue
		for player in get_tree().get_nodes_in_group("players"):
			if p["hit_set"].has(player):
				continue
			if p["pos"].distance_to(player.global_position) < 14.0:
				player.take_damage(12, p["vel"].normalized() * 30.0)
				p["hit_set"].append(player)
	for i in expired:
		metadata_projectiles.remove_at(i)
	if not metadata_projectiles.is_empty():
		queue_redraw()

func _draw_enemy() -> void:
	var chrome := Color(0.75, 0.80, 0.85)
	var accent := Color(0.3, 0.6, 1.0) if vulnerability_open else Color(0.9, 0.2, 0.1)
	var fx := 1 if facing_right else -1

	# Chrome legs
	draw_rect(Rect2(-12, -20, 9, 20), chrome)
	draw_rect(Rect2(3, -20, 9, 20), chrome)
	draw_rect(Rect2(-14, -4, 11, 5), Color(0.5, 0.5, 0.6))
	draw_rect(Rect2(3, -4, 11, 5), Color(0.5, 0.5, 0.6))

	# Chrome body
	draw_rect(Rect2(-14, -52, 28, 32), chrome)

	# Chest display — current time signature
	var chest_col := Color(0.1, 0.1, 0.15)
	draw_rect(Rect2(-10, -48, 20, 20), chest_col)
	# Meter display (bars representing beats)
	for b in range(current_meter):
		var beat_x := -9.0 + b * (18.0 / current_meter)
		var is_current = fmod(beat_clock / beat_period, current_meter) < b + 1 and fmod(beat_clock / beat_period, current_meter) >= b
		var bar_col := accent if is_current else Color(0.3, 0.4, 0.5)
		draw_rect(Rect2(beat_x, -46, 18.0 / current_meter - 1, 14), bar_col)

	# Vulnerability indicator ring
	if vulnerability_open:
		draw_arc(Vector2(0, -36), 16.0, 0, TAU, 24, Color(0.3, 1.0, 0.4, 0.8), 2.5)

	# Invulnerable deflect flash
	if invulnerable_flash > 0.0:
		draw_arc(Vector2(0, -36), 18.0, 0, TAU, 24, Color(1.0, 0.3, 0.1, invulnerable_flash / 0.3), 3.0)

	# Chrome head
	draw_circle(Vector2(0, -62), 14.0, chrome)
	# Visor / face screen
	draw_rect(Rect2(-9, -68, 18, 10), Color(0.15, 0.15, 0.25))
	# Scrolling metadata text (simulated as lines)
	for row in range(3):
		var line_w := 12.0 - row * 3.0
		var scroll_x = fmod(-Time.get_ticks_msec() * 0.02 + row * 6, 20) - 10
		draw_rect(Rect2(scroll_x, -67 + row * 3, line_w, 2), accent)

	# Arms
	draw_rect(Rect2(-26, -52, 12, 24), chrome)
	draw_rect(Rect2(14, -52, 12, 24), chrome)
	# Hands — emit projectiles from here
	draw_circle(Vector2(-20, -28), 6.0, Color(0.4, 0.5, 0.7))
	draw_circle(Vector2(20, -28), 6.0, Color(0.4, 0.5, 0.7))

	# Metadata projectiles
	for proj in metadata_projectiles:
		var lp = to_local(proj["pos"])
		draw_circle(lp, 5.0, Color(0.3, 0.6, 0.9, 0.8))
		draw_arc(lp, 7.0, 0, TAU, 8, Color(0.6, 0.8, 1.0, 0.5), 1.5)

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-30, -86, 60, 5), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-30, -86, 60 * hp_ratio, 5), Color(0.3, 0.6, 1.0))

	if transitioning:
		draw_arc(Vector2(0, -62), 20.0, 0, TAU, 32, Color(1.0, 0.5, 0.0, 0.7), 3.0)
