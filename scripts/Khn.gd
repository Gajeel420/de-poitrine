## KHN — The Harmonic Fighter
## Wields his custom double-neck microtonal instrument as a bass cannon and melee weapon.
## Special: LOOP STATION — shockwave rings that radiate outward hitting all enemies in radius.
class_name Khn
extends Player

var loop_rings: Array[Dictionary] = []  # active shockwave rings

func _ready() -> void:
	player_id = 1
	max_health = 130
	move_speed = 130.0
	attack_damage = 14
	kick_damage = 12
	special_damage = 40
	super._ready()

func _init_sprite() -> void:
	if not ResourceLoader.exists(SpriteSheetConfig.SHEET_PATH):
		return
	var tex := load(SpriteSheetConfig.SHEET_PATH) as Texture2D
	if not tex:
		return
	var sf := SpriteSheetConfig.build_sprite_frames(
		tex,
		SpriteSheetConfig.khn_idle_frames(),
		SpriteSheetConfig.khn_walk_frames(),
		SpriteSheetConfig.khn_attack_frames()
	)
	_setup_animated_sprite(sf)

# ──────────────────────────────────────────────
#  SPECIAL: LOOP STATION
# ──────────────────────────────────────────────

func _do_special() -> void:
	state = State.SPECIAL
	attack_timer = 0.9
	loop_rings.clear()
	# Fire three successive shockwave rings
	for i in range(3):
		await get_tree().create_timer(0.22 * i).timeout
		loop_rings.append({
			"radius": 10.0,
			"max_radius": 130.0,
			"alpha": 1.0,
			"hit_set": [],
		})
	await get_tree().create_timer(0.7).timeout
	if state == State.SPECIAL:
		state = State.IDLE

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_loop_rings(delta)

func _update_loop_rings(delta: float) -> void:
	var done: Array[int] = []
	for i in range(loop_rings.size()):
		var ring: Dictionary = loop_rings[i]
		ring["radius"] += 180.0 * delta
		ring["alpha"] = 1.0 - ring["radius"] / ring["max_radius"]
		# Damage enemies within ring band
		var inner := ring["radius"] - 12.0
		var outer := ring["radius"]
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if ring["hit_set"].has(enemy):
				continue
			var dist := enemy.global_position.distance_to(global_position)
			if dist >= inner and dist <= outer:
				enemy.take_damage(special_damage, Vector2.ZERO)
				ring["hit_set"].append(enemy)
				GameManager.add_score(25)
		if ring["radius"] >= ring["max_radius"]:
			done.append(i)
	for i in done:
		loop_rings.remove_at(i)
	if not loop_rings.is_empty():
		queue_redraw()

# ──────────────────────────────────────────────
#  DRAWING
# ──────────────────────────────────────────────

func _draw_character(jy: float) -> void:
	super._draw_character(jy)
	_draw_guitar(jy)
	_draw_loop_rings()

func _draw_guitar(jy: float) -> void:
	var fx := 1 if facing_right else -1
	# Double-neck guitar body (Strat + Precision bass hybrid)
	var gx := fx * 14
	var gy := jy - 28.0

	# Body
	draw_rect(Rect2(gx - 6, gy - 4, 12, 18), Color(0.55, 0.20, 0.10))
	# Upper neck
	draw_rect(Rect2(gx + fx * 2, gy - 30, fx * 3, 28), Color(0.65, 0.45, 0.20))
	# Lower neck
	draw_rect(Rect2(gx - fx * 2, gy - 28, fx * 3, 26), Color(0.60, 0.40, 0.18))

	# Phosphorescent fret markers (glow green)
	var neck_x := float(gx + fx * 3)
	for f in range(4):
		var fy := gy - 8.0 - f * 6.0
		draw_circle(Vector2(neck_x, fy), 1.5, Color(0.2, 1.0, 0.4, 0.85))

	# Strings (thin lines)
	for s in range(3):
		draw_line(
			Vector2(gx + fx * 3, gy - 30 + s * 3),
			Vector2(gx + fx * 3, gy - 2 + s * 2),
			Color(0.85, 0.85, 0.6, 0.6), 0.5
		)

func _draw_loop_rings() -> void:
	for ring in loop_rings:
		var col := Color(0.3, 0.9, 1.0, ring["alpha"] * 0.8)
		var r: float = ring["radius"]
		# Draw arc in 48 segments
		var pts := PackedVector2Array()
		for i in range(49):
			var a := i * TAU / 48.0
			pts.append(Vector2(cos(a) * r, sin(a) * r * 0.4))  # flatten for belt view
		for i in range(48):
			draw_line(pts[i], pts[i + 1], col, 2.0)
		# Inner glow ring
		var col2 := Color(0.6, 1.0, 1.0, ring["alpha"] * 0.4)
		var r2 := r - 8.0
		if r2 > 0:
			var pts2 := PackedVector2Array()
			for i in range(49):
				var a := i * TAU / 48.0
				pts2.append(Vector2(cos(a) * r2, sin(a) * r2 * 0.4))
			for i in range(48):
				draw_line(pts2[i], pts2[i + 1], col2, 1.0)

func _draw_arms(jy: float, fx: int) -> void:
	# KHN swings guitar in attack — wider arc
	var arm_y := jy - 28.0
	if state in [State.ATTACK1, State.ATTACK2, State.ATTACK3]:
		var t := 1.0 - max(attack_timer, 0.0) / attack_duration
		var swing_angle := -PI * 0.6 * t * fx
		var arm_end := Vector2(cos(swing_angle) * 22, sin(swing_angle) * 22 + arm_y)
		draw_line(Vector2(0, arm_y), arm_end, Color(0.08, 0.08, 0.08), 5)
		# Guitar head at arm end
		draw_circle(arm_end, 5, Color(0.55, 0.20, 0.10))
	else:
		draw_line(Vector2(-10, arm_y), Vector2(-18, arm_y + 8), Color(0.08, 0.08, 0.08), 4)
		draw_line(Vector2(10, arm_y), Vector2(18, arm_y + 6), Color(0.08, 0.08, 0.08), 4)
