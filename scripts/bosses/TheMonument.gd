## STAGE 5 BOSS — The Pyramide des Ha! Ha! (The Monument Itself)
## Puzzle boss: strike each SPEC-13-corrupted yield sign in correct quarter-tone order.
## KHN's LOOP STATION auto-tunes to correct frequency with perfect timing.
class_name TheMonument
extends Boss

# The yield signs = nodes to strike in order (quarter-tone sequence)
const NUM_SIGNS: int = 8
var sign_states: Array[int] = []   # 0=corrupted, 1=restored, 2=highlighted (next target)
var sign_positions: Array[Vector2] = []
var current_target_sign: int = 0
var wrong_hit_penalty: float = 0.0
var restoration_glow: Array[float] = []
var phase3_spawned: bool = false

func _ready() -> void:
	max_health = 450
	move_speed = 0.0  # doesn't move
	attack_damage = 20
	attack_range = 0.0  # attacks via signs
	score_value = 1400
	phase_thresholds = [0.6, 0.25]
	max_phases = 3
	enemy_color = Color(0.72, 0.55, 0.22)  # sandstone pyramid

	# Place yield signs in a semicircle around the monument
	sign_states.clear()
	sign_positions.clear()
	restoration_glow.clear()
	for i in range(NUM_SIGNS):
		sign_states.append(0)
		var angle := -PI * 0.8 + i * (PI * 1.6 / (NUM_SIGNS - 1))
		sign_positions.append(Vector2(cos(angle) * 120, sin(angle) * 40))
		restoration_glow.append(0.0)

	sign_states[0] = 2  # highlight first target
	super._ready()

func _physics_process(delta: float) -> void:
	# Monument doesn't use normal AI — override physics entirely
	velocity = Vector2.ZERO
	wrong_hit_penalty -= delta

	for i in range(NUM_SIGNS):
		if restoration_glow[i] > 0.0:
			restoration_glow[i] -= delta * 2.0

	# Periodically shoot corrupted energy from un-restored signs
	if Engine.get_process_frames() % 120 == 0:
		_pulse_attack()

	# Check if players are punching near a sign
	_check_sign_hits()

	boss_health_changed.emit(health, max_health)
	queue_redraw()

	if state == State.DEAD:
		return

func _pulse_attack() -> void:
	for i in range(NUM_SIGNS):
		if sign_states[i] == 0:  # still corrupted
			var sign_world_pos := global_position + sign_positions[i]
			for p in get_tree().get_nodes_in_group("players"):
				if sign_world_pos.distance_to(p.global_position) < 60.0:
					p.take_damage(14, (p.global_position - sign_world_pos).normalized() * 50.0)

func _check_sign_hits() -> void:
	for p in get_tree().get_nodes_in_group("players"):
		if p.state not in [Player.State.ATTACK1, Player.State.ATTACK2, Player.State.ATTACK3, Player.State.SPECIAL]:
			continue
		var sign_idx_hit := -1
		var hit_box = p._get_attack_hitbox()
		for i in range(NUM_SIGNS):
			if sign_states[i] != 0:
				continue
			var sign_world := global_position + sign_positions[i]
			if hit_box.has_point(sign_world):
				sign_idx_hit = i
				break

		if sign_idx_hit < 0:
			continue

		if sign_idx_hit == current_target_sign:
			# Correct sign!
			_restore_sign(sign_idx_hit, p)
		else:
			# Wrong sign — wrong quarter-tone pitch
			wrong_hit_penalty = 0.8
			GameManager.trigger_screen_shake(3.0, 0.2)
			p.take_damage(12, Vector2.ZERO)
			take_damage(0)  # no damage but register attempt

func _restore_sign(idx: int, player: Node2D) -> void:
	sign_states[idx] = 1
	restoration_glow[idx] = 1.0
	GameManager.trigger_screen_shake(4.0, 0.2)
	GameManager.add_score(200)

	current_target_sign += 1
	if current_target_sign < NUM_SIGNS:
		sign_states[current_target_sign] = 2  # next target
	else:
		# All restored — damage monument
		var total_dmg := int(max_health * 0.34)
		super.take_damage(total_dmg, Vector2.ZERO)
		current_target_sign = 0
		for i in range(NUM_SIGNS):
			if sign_states[i] == 1:
				sign_states[i] = 0
		sign_states[0] = 2

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if amount == 0:
		return
	health -= amount
	health = max(health, 0)
	boss_health_changed.emit(health, max_health)
	if health <= 0:
		_die()
		return
	_check_phase_transition()

func _draw_enemy() -> void:
	# Giant pyramid structure
	var stone := Color(0.68, 0.58, 0.38)
	var stone_dark := Color(0.52, 0.44, 0.28)

	# Pyramid body (triangle)
	draw_colored_polygon(
		PackedVector2Array([Vector2(0, -100), Vector2(-90, 0), Vector2(90, 0)]),
		stone
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(0, -100), Vector2(20, -60), Vector2(90, 0)]),
		stone_dark
	)

	# Stone blocks (horizontal lines)
	for row in range(6):
		var y := -90 + row * 16
		var w := 12 + row * 16
		draw_line(Vector2(-w, y), Vector2(w, y), Color(0.45, 0.38, 0.24, 0.4), 1.0)

	# Yield signs (yield signs = triangles)
	for i in range(NUM_SIGNS):
		var sp := sign_positions[i]
		var s_state := sign_states[i]
		var sign_col: Color
		match s_state:
			0:  # corrupted — SPEC-13 logo (inverted triangle blue)
				sign_col = Color(0.2, 0.3, 0.9)
			1:  # restored — yield sign (warm orange)
				sign_col = Color(0.95, 0.65, 0.1)
			2:  # highlighted target
				var pulse = abs(sin(Time.get_ticks_msec() * 0.005)) * 0.4 + 0.6
				sign_col = Color(1.0, 0.9, 0.1, pulse)

		var sz := 12.0
		if s_state == 0:
			# Inverted triangle (SPEC-13)
			draw_colored_polygon(
				PackedVector2Array([sp + Vector2(0, sz), sp + Vector2(-sz, -sz * 0.6), sp + Vector2(sz, -sz * 0.6)]),
				sign_col
			)
		else:
			# Normal yield triangle
			draw_colored_polygon(
				PackedVector2Array([sp + Vector2(0, -sz), sp + Vector2(-sz, sz * 0.6), sp + Vector2(sz, sz * 0.6)]),
				sign_col
			)

		# Restoration glow
		if restoration_glow[i] > 0.0:
			draw_arc(sp, sz * 1.8, 0, TAU, 16, Color(1.0, 0.9, 0.3, restoration_glow[i]), 3.0)

	# Wrong-hit flash
	if wrong_hit_penalty > 0.0:
		draw_arc(Vector2(0, -50), 100.0, 0, TAU, 24, Color(0.9, 0.1, 0.1, wrong_hit_penalty * 0.4), 4.0)

	# HP bar
	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-45, -115, 90, 5), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-45, -115, 90 * hp_ratio, 5), Color(0.95, 0.65, 0.1))
