## STAGE 3 BOSS — Impersonator Prime
## Mirrors player moveset exactly. Vulnerable only when KLEK uses ODD METER —
## the algorithm cannot predict asymmetric timing.
class_name ImpersonatorPrime
extends Boss

var mirroring: bool = true  # copies player attack animations
var last_player_attack_time: float = -999.0
var odd_meter_vulnerable: bool = false
var copy_anim_timer: float = 0.0
var copy_state: int = 0   # 0=idle, 1=attack, 2=kick
var invulnerable_flash: float = 0.0

func _ready() -> void:
	max_health = 380
	move_speed = 78.0
	attack_damage = 15
	attack_range = 38.0
	attack_cooldown = 1.8
	score_value = 1100
	phase_thresholds = [0.5]
	enemy_color = Color(0.5, 0.5, 0.5)  # exact grey copy
	super._ready()

func _on_phase_enter(phase: int) -> void:
	if phase == 2:
		move_speed = 100.0
		attack_damage = 20
		# Phase 2: also predicts and dodges

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if not odd_meter_vulnerable and not (state == State.STUNNED):
		invulnerable_flash = 0.25
		GameManager.trigger_screen_shake(1.0, 0.06)
		return
	super.take_damage(amount, knockback)

func enter_odd_meter(duration: float) -> void:
	odd_meter_vulnerable = true
	super.enter_odd_meter(duration)
	await get_tree().create_timer(duration).timeout
	odd_meter_vulnerable = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	copy_anim_timer -= delta
	invulnerable_flash -= delta

	# Mirror player attacks visually
	for p in get_tree().get_nodes_in_group("players"):
		if p.state in [Player.State.ATTACK1, Player.State.ATTACK2, Player.State.ATTACK3]:
			last_player_attack_time = Time.get_ticks_msec() / 1000.0
			copy_state = 1
			copy_anim_timer = 0.3

	if copy_anim_timer <= 0.0:
		copy_state = 0

	# Phase 2: dodge predictively
	if current_phase == 2:
		for p in get_tree().get_nodes_in_group("players"):
			if p.state in [Player.State.ATTACK1, Player.State.ATTACK2, Player.State.ATTACK3]:
				var away: Vector2 = (global_position - p.global_position).normalized()
				velocity += away * 120.0

func _draw_enemy() -> void:
	# A perfect mirror of the polka-dot suit, but rendered in grey with wrong seams
	var suit := Color(0.55, 0.55, 0.55)   # grey copy
	var skin := Color(0.82, 0.72, 0.60)
	var shoe := Color(0.22, 0.17, 0.12)
	var dot := Color(0.9, 0.9, 0.9)   # almost white but slightly off
	var fx := 1 if facing_right else -1

	# Legs
	var swing := sin(float(Engine.get_process_frames()) * 0.3) * 4.0
	draw_rect(Rect2(-9, -16, 7, 16), suit)
	draw_rect(Rect2(2, -16, 7, 16 + swing), suit)
	draw_rect(Rect2(-11, -4, 9, 4), shoe)
	draw_rect(Rect2(2, -4, 9, 4), shoe)

	# Body
	draw_rect(Rect2(-10, -34, 20, 18), suit)

	# Polka dots (wrong — slightly too many, asymmetric)
	var wrong_dots := [
		Vector2(-7, -30), Vector2(2, -24), Vector2(-2, -18),
		Vector2(6, -32), Vector2(-5, -16), Vector2(3, -13), Vector2(-8, -22),
	]
	for dp in wrong_dots:
		draw_circle(dp, 2.2, dot)

	# Head
	draw_circle(Vector2(0, -44), 10.0, skin)
	draw_circle(Vector2(fx * 3, -45), 2.0, Color(0.1, 0.1, 0.1))

	# Nose — perfectly calibrated length, somehow more unnerving
	draw_line(Vector2(fx * 4, -43), Vector2(fx * 14, -40), Color(0.72, 0.52, 0.32), 2.5)

	# Arms (copy attack animation)
	var arm_swing := 0.0
	if copy_state == 1:
		arm_swing = 16.0 * (1.0 - copy_anim_timer / 0.3)
	draw_line(Vector2(-10, -30), Vector2(-18 + arm_swing * 0.3, -24), Color(0.55, 0.55, 0.55), 5)
	draw_line(Vector2(10, -30), Vector2(18 + arm_swing * fx, -26), Color(0.55, 0.55, 0.55), 5)

	# Fake guitar (grey, wrong proportions)
	draw_rect(Rect2(fx * 12, -32, fx * 7, 16), Color(0.45, 0.18, 0.08))
	draw_rect(Rect2(fx * 14, -46, fx * 3, 16), Color(0.58, 0.40, 0.18))

	# Vulnerability glow (ODD METER)
	if odd_meter_vulnerable or state == State.STUNNED:
		draw_arc(Vector2(0, -28), 26.0, 0, TAU, 32, Color(1.0, 0.4, 0.0, 0.7), 2.5)

	if invulnerable_flash > 0.0:
		draw_arc(Vector2(0, -28), 20.0, 0, TAU, 24, Color(0.8, 0.8, 0.8, invulnerable_flash / 0.25), 3.0)

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-30, -70, 60, 5), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-30, -70, 60 * hp_ratio, 5), Color(0.7, 0.7, 0.1))

	if transitioning:
		draw_arc(Vector2(0, -44), 18.0, 0, TAU, 32, Color(1.0, 0.5, 0.0, 0.7), 3.0)
