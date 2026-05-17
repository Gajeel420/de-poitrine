## STAGE 6 FINAL BOSS — Fabio Spek-Trois
## 3 phases tied to the 3 vinyl pressings in the glass case.
## Not defeated by destruction — by playing the full synchronized LOOP STATION sequence.
## Phase 3: wields a cheap guitar knockoff. Final defeat: rewrites the SPEC-13 algorithm.
class_name FabioSpekTrois
extends Boss

var vinyl_case_intact: Array[bool] = [true, true, true]  # 3 pressings
var loop_sequence_progress: int = 0   # 0-3, completing 3 = win
var loop_timer: float = 0.0
var loop_window: float = 0.0  # opening for loop sequence input
var loop_window_timer: float = 0.0
var absorbed_energy: float = 0.0  # increases each phase
var synthetic_pulses: Array[Dictionary] = []
var pulse_timer: float = 0.0
var final_sequence_active: bool = false
var final_sequence_timer: float = 0.0
var suit_quality: Color = Color(0.25, 0.22, 0.30)  # expensive suit

func _ready() -> void:
	max_health = 600
	move_speed = 65.0
	attack_damage = 18
	attack_range = 38.0
	attack_cooldown = 2.0
	score_value = 3000
	phase_thresholds = [0.66, 0.33]
	max_phases = 3
	enemy_color = suit_quality
	super._ready()

func _on_phase_enter(phase: int) -> void:
	vinyl_case_intact[phase - 2] = false  # previous pressing shattered
	absorbed_energy = float(phase - 1) * 0.4
	match phase:
		2:
			move_speed = 80.0
			attack_damage = 22
			attack_cooldown = 1.6
			suit_quality = Color(0.4, 0.35, 0.55)  # suit glows with stolen energy
		3:
			move_speed = 90.0
			attack_damage = 28
			attack_cooldown = 1.2
			suit_quality = Color(0.6, 0.4, 0.8)  # glowing purple
			# Phase 3: opens loop sequence window
			_open_loop_window()

func _open_loop_window() -> void:
	# Window for players to complete the loop sequence
	loop_window = 1.0
	loop_window_timer = 8.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	pulse_timer -= delta
	loop_window_timer -= delta

	if loop_window_timer > 0.0 and current_phase == 3:
		loop_window = loop_window_timer / 8.0
	else:
		loop_window = 0.0

	if pulse_timer <= 0.0:
		_fire_synthetic_pulse()
		pulse_timer = 1.5 - absorbed_energy * 0.5

	_update_pulses(delta)
	_check_loop_input()

	if final_sequence_active:
		final_sequence_timer += delta
		if final_sequence_timer >= 6.0:
			_algorithm_rewritten()

func _fire_synthetic_pulse() -> void:
	var target_player: Node2D = null
	var nearest_dist := INF
	for p in get_tree().get_nodes_in_group("players"):
		var d := global_position.distance_to(p.global_position)
		if d < nearest_dist:
			nearest_dist = d
			target_player = p
	if not target_player:
		return

	var dir := (target_player.global_position - global_position).normalized()
	synthetic_pulses.append({
		"pos": Vector2(global_position),
		"vel": dir * (100.0 + absorbed_energy * 80.0),
		"life": 2.8,
		"hit_set": [],
		"energy": absorbed_energy,
	})

func _update_pulses(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(synthetic_pulses.size()):
		var p: Dictionary = synthetic_pulses[i]
		p["pos"] += p["vel"] * delta
		p["life"] -= delta
		if p["life"] <= 0.0:
			expired.append(i)
			continue
		for player in get_tree().get_nodes_in_group("players"):
			if p["hit_set"].has(player):
				continue
			if p["pos"].distance_to(player.global_position) < 16.0:
				player.take_damage(int(attack_damage * 0.7 + p["energy"] * 8), p["vel"].normalized() * 40.0)
				p["hit_set"].append(player)
	for i in expired:
		synthetic_pulses.remove_at(i)
	if not synthetic_pulses.is_empty():
		queue_redraw()

func _check_loop_input() -> void:
	if current_phase < 3 or final_sequence_active:
		return
	# Look for KHN using LOOP STATION
	for p in get_tree().get_nodes_in_group("players"):
		if p is Khn and p.state == Player.State.SPECIAL:
			loop_sequence_progress += 1
			GameManager.trigger_screen_shake(3.0, 0.2)
			if loop_sequence_progress >= 3:
				_start_final_sequence()
			else:
				_open_loop_window()
			return

func _start_final_sequence() -> void:
	final_sequence_active = true
	final_sequence_timer = 0.0
	state = State.STUNNED
	stunned_timer = 99.0  # hold until algorithm is rewritten
	GameManager.trigger_screen_shake(8.0, 0.8)

func _algorithm_rewritten() -> void:
	# Victory — not by destroying Fabio, but by rewriting his algorithm
	vinyl_case_intact[2] = false
	health = 0
	_die()

func _draw_enemy() -> void:
	var fx := 1 if facing_right else -1
	var skin := Color(0.82, 0.70, 0.58)
	var suit := suit_quality
	var energy_glow := Color(0.7, 0.4, 1.0, absorbed_energy * 0.6)

	# Expensive suit
	draw_rect(Rect2(-10, -16, 8, 16), suit)
	draw_rect(Rect2(2, -16, 8, 16), suit)
	draw_rect(Rect2(-12, -5, 10, 5), Color(0.1, 0.08, 0.05))  # shoes
	draw_rect(Rect2(2, -5, 10, 5), Color(0.1, 0.08, 0.05))
	draw_rect(Rect2(-12, -40, 24, 24), suit)
	# Lapels
	draw_rect(Rect2(-8, -38, 5, 18), Color(0.35, 0.30, 0.40))
	draw_rect(Rect2(3, -38, 5, 18), Color(0.35, 0.30, 0.40))
	# Silk tie
	draw_rect(Rect2(-2, -38, 5, 22), Color(0.8, 0.15, 0.15))

	# Absorbed energy aura
	if absorbed_energy > 0.0:
		draw_arc(Vector2(0, -24), 20.0, 0, TAU, 24, energy_glow, 2.0)

	# Head — slick, expensive hair
	draw_circle(Vector2(0, -50), 11.0, skin)
	# Hair (dark, product-perfect)
	draw_arc(Vector2(0, -56), 9.0, PI, TAU, 12, Color(0.12, 0.10, 0.08), 3.0)
	# Eyes — calculating
	draw_circle(Vector2(fx * -3, -52), 2.0, Color(0.12, 0.10, 0.08))
	draw_circle(Vector2(fx * 3, -52), 2.0, Color(0.12, 0.10, 0.08))
	# Smirk
	draw_arc(Vector2(fx * 2, -46), 5.0, 0, PI * 0.9, 8, Color(0.25, 0.15, 0.15), 1.5)

	# Phase 3: cheap guitar knockoff
	if current_phase == 3:
		draw_rect(Rect2(fx * 14, -38, fx * 8, 20), Color(0.30, 0.12, 0.05))
		draw_rect(Rect2(fx * 16, -54, fx * 4, 18), Color(0.40, 0.28, 0.14))
		# It's wrong — one neck, off-color, mass-produced
		for s in range(2):
			draw_line(
				Vector2(fx * 18, -54 + s * 4),
				Vector2(fx * 18, -36 + s * 3),
				Color(0.7, 0.7, 0.5, 0.4), 0.5
			)

	# Vinyl glass case (behind Fabio)
	draw_rect(Rect2(fx * -40, -52, 30, 44), Color(0.4, 0.6, 0.8, 0.3))
	draw_rect(Rect2(fx * -40, -52, 30, 44), Color(0.6, 0.8, 1.0, 0.15), false)
	for i in range(3):
		if vinyl_case_intact[i]:
			var vy := -48 + i * 14
			draw_rect(Rect2(fx * -36, vy, 22, 12), Color(0.08, 0.08, 0.08))
			draw_circle(Vector2(fx * -25, vy + 6), 3.5, Color(0.4, 0.4, 0.4))
			draw_circle(Vector2(fx * -25, vy + 6), 1.5, Color(0.08, 0.08, 0.08))

	# Synthetic energy pulses
	for pulse in synthetic_pulses:
		var lp := to_local(pulse["pos"])
		var pc := Color(0.7 + pulse["energy"] * 0.3, 0.3 - pulse["energy"] * 0.1, 1.0, 0.85)
		draw_circle(lp, 6.0 + pulse["energy"] * 4.0, pc)
		draw_arc(lp, 9.0, 0, TAU, 12, Color(1.0, 0.6, 1.0, 0.5), 1.5)

	# Final sequence — algorithm rewriting glow
	if final_sequence_active:
		var prog := final_sequence_timer / 6.0
		draw_arc(Vector2(0, -30), 50.0 * prog, 0, TAU * prog, 32, Color(0.3, 1.0, 0.5, 0.8), 3.0)
		for i in range(6):
			var a := i * TAU / 6.0 + final_sequence_timer * 2.0
			var r := 40.0 * prog
			draw_circle(Vector2(cos(a) * r, sin(a) * r * 0.4 - 30), 4.0, Color(0.2, 1.0, 0.4, 0.7))

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-40, -76, 80, 5), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-40, -76, 80 * hp_ratio, 5), Color(0.7, 0.4, 1.0))

	# Loop sequence progress
	if current_phase == 3:
		for i in range(3):
			var filled := i < loop_sequence_progress
			draw_arc(Vector2(-20 + i * 20, -83), 6.0, 0, TAU, 12,
				Color(0.3, 1.0, 0.5) if filled else Color(0.3, 0.3, 0.4), 2.0)

	if transitioning:
		draw_arc(Vector2(0, -50), 22.0, 0, TAU, 32, Color(1.0, 0.5, 0.0, 0.7), 3.0)
