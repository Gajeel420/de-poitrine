## Base class for all 6 stages. Manages waves, camera scroll, and background drawing.
class_name StageBase
extends Node2D

signal stage_cleared
signal boss_spawned(boss: Boss)

# --- Configuration (set by subclass) ---
var stage_number: int = 1
var stage_width: float = 3000.0   # total scrollable width
var scroll_x: float = 0.0         # current camera scroll
var scroll_speed: float = 40.0    # auto-scroll speed when path is clear
var scroll_locked: bool = true    # locked until wave is cleared
var scroll_limit: float = 0.0     # maximum scroll (set by waves)

var waves: Array[Dictionary] = []  # populated by subclass
var current_wave_index: int = -1
var wave_in_progress: bool = false
var boss_wave: bool = false
var boss_alive: bool = false
var all_waves_done: bool = false

# --- Players ---
var players: Array[Node2D] = []

# --- HUD reference ---
var hud: Node = null

# Background scroll layers (parallax)
var bg_scroll_1: float = 0.0  # slow layer
var bg_scroll_2: float = 0.0  # mid layer

# Stage intro shown flag
var intro_shown: bool = false

# Floor bounds
const FLOOR_Y_MIN: float = 230.0
const FLOOR_Y_MAX: float = 310.0
const VISIBLE_WIDTH: float = 640.0

func _ready() -> void:
	_setup_hud()
	_setup_players()
	_setup_waves()
	call_deferred("_show_intro")

func _setup_players() -> void:
	if GameManager.num_players >= 2:
		# 2P: KHN=P1, KLEK=P2
		var p1 := _spawn_character(load("res://scripts/Khn.gd"), Vector2(80, 270), 1)
		var p2 := _spawn_character(load("res://scripts/Klek.gd"), Vector2(120, 280), 2)
		players = [p1, p2]
	else:
		# 1P: use whichever character was selected
		var script: Script
		if GameManager.selected_character == 1:
			script = load("res://scripts/Klek.gd")
		else:
			script = load("res://scripts/Khn.gd")
		var p1 := _spawn_character(script, Vector2(100, 270), 1)
		players = [p1]

func _spawn_character(script: Script, pos: Vector2, pid: int) -> Node2D:
	var body := CharacterBody2D.new()
	body.set_script(script)
	body.position = pos
	add_child(body)
	body.died.connect(_on_player_died)
	body.health_changed.connect(func(hp, mx): if hud: hud.update_player_hp(pid, hp, mx))
	body.special_changed.connect(func(v, mx): if hud: hud.update_player_special(pid, v, mx))
	return body

func _setup_hud() -> void:
	var hud_script := load("res://scripts/HUD.gd")
	var hud_node := CanvasLayer.new()
	hud_node.set_script(hud_script)
	hud_node.name = "HUD"
	add_child(hud_node)
	hud = hud_node
	hud.stage_number = stage_number
	hud.num_players = GameManager.num_players

func _show_intro() -> void:
	if intro_shown:
		return
	intro_shown = true
	# Brief title card
	var intro_script := load("res://scripts/StageIntro.gd")
	var intro := Control.new()
	intro.set_script(intro_script)
	intro.name = "StageIntro"
	add_child(intro)
	intro.show_intro(
		GameManager.STAGE_NAMES[stage_number],
		GameManager.STAGE_LOCATIONS[stage_number],
		_get_lore_text()
	)
	await get_tree().create_timer(3.2).timeout
	_start_next_wave()

func _get_lore_text() -> String:
	return ""  # Override in subclass

func _setup_waves() -> void:
	pass  # Override in subclass to populate waves[]

# ──────────────────────────────────────────────
#  WAVE MANAGEMENT
# ──────────────────────────────────────────────

func _start_next_wave() -> void:
	current_wave_index += 1
	if current_wave_index >= waves.size():
		all_waves_done = true
		_on_all_waves_cleared()
		return

	var wave: Dictionary = waves[current_wave_index]
	wave_in_progress = true
	scroll_locked = true
	scroll_limit = wave.get("scroll_to", scroll_limit)
	boss_wave = wave.get("is_boss", false)

	# Spawn enemies for this wave
	var spawns: Array = wave.get("enemies", [])
	for spawn_data in spawns:
		await get_tree().create_timer(spawn_data.get("delay", 0.0)).timeout
		_spawn_enemy(spawn_data)

func _spawn_enemy(spawn_data: Dictionary) -> void:
	var script_path: String = spawn_data.get("script", "")
	if script_path.is_empty():
		return

	var enemy_script := load(script_path)
	var enemy := CharacterBody2D.new()
	enemy.set_script(enemy_script)
	enemy.position = Vector2(
		spawn_data.get("x", 400) + scroll_x,
		spawn_data.get("y", 260)
	)

	# Formation offset for StreamingDrone
	if enemy.has_method("set_formation_offset"):
		enemy.set_formation_offset(spawn_data.get("formation_offset", Vector2.ZERO))

	add_child(enemy)

	if boss_wave:
		boss_alive = true
		enemy.died.connect(_on_boss_died)
		boss_spawned.emit(enemy)
		if hud:
			hud.show_boss_hp(enemy)
		if spawn_data.get("sync_formation", false):
			enemy.sync_offset = spawn_data.get("formation_offset", Vector2.ZERO).x * 0.01
	else:
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy) -> void:
	# Check if wave is cleared
	await get_tree().process_frame
	var remaining := get_tree().get_nodes_in_group("enemies").size()
	if remaining == 0 and wave_in_progress:
		wave_in_progress = false
		scroll_locked = false
		await get_tree().create_timer(0.8).timeout
		_start_next_wave()

func _on_boss_died(boss: Boss) -> void:
	boss_alive = false
	wave_in_progress = false
	scroll_locked = false
	GameManager.trigger_screen_shake(10.0, 1.0)
	await get_tree().create_timer(2.5).timeout
	stage_cleared.emit()
	await get_tree().create_timer(1.0).timeout
	GameManager.advance_stage()

func _on_player_died(player_id: int) -> void:
	var alive := 0
	for p in players:
		if p.state != Player.State.DEAD:
			alive += 1
	if alive == 0:
		await get_tree().create_timer(1.5).timeout
		GameManager.game_over()

func _on_all_waves_cleared() -> void:
	pass  # Override if needed (most stages end on boss kill)

# ──────────────────────────────────────────────
#  CAMERA / SCROLL
# ──────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_scroll(delta)
	_update_parallax(delta)
	queue_redraw()

func _update_scroll(delta: float) -> void:
	if players.is_empty():
		return

	# Find rightmost player
	var max_player_x := 0.0
	for p in players:
		if is_instance_valid(p) and p.state != Player.State.DEAD:
			max_player_x = max(max_player_x, p.global_position.x)

	# Desired scroll: keep players in right third of screen
	var desired_scroll := max_player_x - VISIBLE_WIDTH * 0.65

	if not scroll_locked:
		# Auto-advance scroll
		scroll_x = move_toward(scroll_x, min(desired_scroll, scroll_limit), scroll_speed * delta)
	else:
		# Just follow players within the locked zone
		scroll_x = move_toward(scroll_x, desired_scroll, scroll_speed * 0.5 * delta)

	# Simulate camera by offsetting entire stage node inversely
	position.x = -scroll_x

	# Clamp players to left edge of visible area
	for p in players:
		if is_instance_valid(p):
			p.position.x = max(p.position.x, scroll_x + 30)

func _update_parallax(delta: float) -> void:
	bg_scroll_1 = scroll_x * 0.3
	bg_scroll_2 = scroll_x * 0.6

func _physics_process(_delta: float) -> void:
	# Apply shake to viewport canvas transform
	var shake := GameManager.get_shake_offset()
	if not shake.is_zero_approx():
		get_tree().root.canvas_transform = Transform2D(0.0, shake)
	else:
		get_tree().root.canvas_transform = Transform2D.IDENTITY

# ──────────────────────────────────────────────
#  DRAWING
# ──────────────────────────────────────────────

func _draw() -> void:
	_draw_background()
	_draw_floor()

func _draw_background() -> void:
	# Override in subclass for unique stage backgrounds
	draw_rect(Rect2(0, 0, 640, 360), Color(0.08, 0.08, 0.12))

func _draw_floor() -> void:
	# Ground plane
	draw_rect(Rect2(0, FLOOR_Y_MIN - 10, 640, FLOOR_Y_MAX - FLOOR_Y_MIN + 30),
		Color(0.18, 0.14, 0.10))
	# Floor line
	draw_line(Vector2(0, FLOOR_Y_MIN - 10), Vector2(640, FLOOR_Y_MIN - 10),
		Color(0.35, 0.28, 0.20), 2.0)
	# Floor shadow gradient (fake perspective)
	for i in range(6):
		var alpha := (6 - i) / 12.0
		draw_line(
			Vector2(0, FLOOR_Y_MIN - 10 - i * 4),
			Vector2(640, FLOOR_Y_MIN - 10 - i * 4),
			Color(0.0, 0.0, 0.0, alpha), 1.0
		)
