## KLEK — The Rhythmic Disruptor
## Drumstick combos, cymbal throws, asymmetric timing attacks.
## Special: ODD METER — disrupts all enemy AI timing, causing stumble/desync.
class_name Klek
extends Player

var cymbal_projectiles: Array[Dictionary] = []
var odd_meter_active: bool = false
var odd_meter_timer: float = 0.0
const ODD_METER_DURATION: float = 4.5

func _ready() -> void:
	player_id = 2
	max_health = 110
	move_speed = 160.0
	attack_damage = 10
	kick_damage = 18
	special_damage = 30
	super._ready()

func _init_sprite() -> void:
	if not ResourceLoader.exists(SpriteSheetConfig.SHEET_PATH):
		return
	var tex := load(SpriteSheetConfig.SHEET_PATH) as Texture2D
	if not tex:
		return
	var sf := SpriteSheetConfig.build_sprite_frames(
		tex,
		SpriteSheetConfig.klek_idle_frames(),
		SpriteSheetConfig.klek_walk_frames(),
		SpriteSheetConfig.klek_attack_frames()
	)
	_setup_animated_sprite(sf)

# ──────────────────────────────────────────────
#  SPECIAL: ODD METER
# ──────────────────────────────────────────────

func _do_special() -> void:
	state = State.SPECIAL
	attack_timer = 0.6
	odd_meter_active = true
	odd_meter_timer = ODD_METER_DURATION
	GameManager.trigger_screen_shake(5.0, 0.3)

	# Signal all enemies to enter stumble state
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("enter_odd_meter"):
			enemy.enter_odd_meter(ODD_METER_DURATION)

	await get_tree().create_timer(0.6).timeout
	if state == State.SPECIAL:
		state = State.IDLE

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if odd_meter_timer > 0.0:
		odd_meter_timer -= delta
		if odd_meter_timer <= 0.0:
			odd_meter_active = false
	_update_cymbals(delta)

# Klek's kick is a forward-lunge bass drum kick
func _start_kick() -> void:
	super._start_kick()
	# Extra forward lunge
	velocity += Vector2((1 if facing_right else -1) * 80.0, 0)

# Cymbal throw (triggered after a full combo_count=3 chain hits)
func throw_cymbal() -> void:
	cymbal_projectiles.append({
		"pos": Vector2(global_position),
		"vel": Vector2((1 if facing_right else -1) * 220.0, 0),
		"life": 1.2,
		"hit_set": [],
	})

func _update_cymbals(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(cymbal_projectiles.size()):
		var c: Dictionary = cymbal_projectiles[i]
		c["pos"] += c["vel"] * delta
		c["life"] -= delta
		if c["life"] <= 0.0:
			expired.append(i)
			continue
		# Check hits
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if c["hit_set"].has(enemy):
				continue
			if c["pos"].distance_to(enemy.global_position) < 20.0:
				enemy.take_damage(18, c["vel"].normalized() * 40.0)
				c["hit_set"].append(enemy)
				GameManager.add_score(15)
	for i in expired:
		cymbal_projectiles.remove_at(i)
	if not cymbal_projectiles.is_empty():
		queue_redraw()

# Throw cymbal after completing a 3-hit combo
func _start_attack() -> void:
	super._start_attack()
	if combo_count == 0:  # just reset to 0 in parent after 3
		throw_cymbal()

# ──────────────────────────────────────────────
#  DRAWING
# ──────────────────────────────────────────────

func _draw_character(jy: float) -> void:
	super._draw_character(jy)
	_draw_drumsticks(jy)
	_draw_cymbals()
	_draw_odd_meter_aura(jy)

func _draw_drumsticks(jy: float) -> void:
	var fx := 1 if facing_right else -1
	var attack_swing := 0.0
	if state in [State.ATTACK1, State.ATTACK2, State.ATTACK3]:
		attack_swing = PI * 0.7 * (1.0 - max(attack_timer, 0.0) / attack_duration)

	# Left drumstick (always ready)
	var l_angle := -PI * 0.3 + attack_swing * 0.5 * fx
	draw_line(
		Vector2(-8, jy - 30),
		Vector2(-8 + cos(l_angle) * 20, jy - 30 + sin(l_angle) * 20),
		Color(0.65, 0.42, 0.18), 3.0
	)
	# Right drumstick (main strike)
	var r_angle := -PI * 0.5 + attack_swing * fx
	draw_line(
		Vector2(8, jy - 30),
		Vector2(8 + cos(r_angle) * 22, jy - 30 + sin(r_angle) * 22),
		Color(0.65, 0.42, 0.18), 3.0
	)

func _draw_cymbals() -> void:
	for c in cymbal_projectiles:
		var local_pos := to_local(c["pos"])
		# Cymbal as golden ellipse
		draw_arc(local_pos, 8.0, 0, TAU, 16, Color(0.9, 0.75, 0.1), 2.5)
		draw_arc(local_pos, 5.0, 0, TAU, 12, Color(1.0, 0.9, 0.3, 0.5), 1.5)

func _draw_odd_meter_aura(jy: float) -> void:
	if not odd_meter_active:
		return
	var pulse := abs(sin(Time.get_ticks_msec() * 0.006)) * 0.6 + 0.2
	var aura_col := Color(1.0, 0.4, 0.0, pulse)
	draw_arc(Vector2(0, jy - 24), 28.0, 0, TAU, 32, aura_col, 2.0)
	# Wavy lines indicating time distortion
	for i in range(4):
		var angle := i * TAU / 4.0 + Time.get_ticks_msec() * 0.003
		var p1 := Vector2(cos(angle) * 22, (sin(angle) * 22) * 0.4 + jy - 24)
		var p2 := Vector2(cos(angle + 0.4) * 30, (sin(angle + 0.4) * 30) * 0.4 + jy - 24)
		draw_line(p1, p2, Color(1.0, 0.6, 0.0, pulse * 0.7), 1.5)

func _draw_arms(jy: float, fx: int) -> void:
	# Klek's arms are slightly wider, holding drumsticks up
	var arm_y := jy - 28.0
	draw_line(Vector2(-10, arm_y), Vector2(-20, arm_y - 6), Color(0.08, 0.08, 0.08), 4)
	draw_line(Vector2(10, arm_y), Vector2(20, arm_y - 4), Color(0.08, 0.08, 0.08), 4)
