## STAGE 1 BOSS — The Venue Owner
## Giant red-faced bouncer. Phase 1: velvet rope whips. Phase 2: charge + stomp.
class_name VenueOwner
extends Boss

var ropes: Array[Dictionary] = []
var rope_timer: float = 0.0
var is_charging: bool = false
var charge_velocity: Vector2 = Vector2.ZERO
var stomp_timer: float = 0.0
var face_redness: float = 0.5

func _ready() -> void:
	max_health = 350
	move_speed = 55.0
	attack_damage = 18
	attack_range = 50.0
	attack_cooldown = 2.0
	score_value = 1000
	phase_thresholds = [0.5]
	max_phases = 2
	enemy_color = Color(0.36, 0.15, 0.15)
	super._ready()

func _on_phase_enter(phase: int) -> void:
	if phase == 2:
		move_speed = 85.0
		attack_damage = 24
		attack_cooldown = 1.4
		face_redness = 1.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	rope_timer -= delta
	stomp_timer -= delta
	face_redness = lerp(face_redness, 0.5 + float(current_phase - 1) * 0.5, delta * 0.5)

	if state == State.APPROACH and rope_timer <= 0.0:
		_whip_rope()
		rope_timer = 2.8 if current_phase == 1 else 1.8

	if current_phase == 2 and state == State.APPROACH and not is_charging:
		if target and global_position.distance_to(target.global_position) < 200.0:
			if randf() < delta * 0.4:
				_start_charge()

	if is_charging:
		velocity = charge_velocity
		_check_charge_hit()
		charge_velocity = charge_velocity.lerp(Vector2.ZERO, delta * 1.5)
		if charge_velocity.length() < 10.0:
			is_charging = false
			_stomp()

	_update_ropes(delta)

func _whip_rope() -> void:
	if not target:
		return
	var dir := (target.global_position - global_position).normalized()
	# Two rope segments that extend outward
	ropes.append({
		"start": Vector2(global_position),
		"dir": dir,
		"length": 0.0,
		"max_length": 80.0,
		"life": 0.7,
		"hit": false,
	})

func _update_ropes(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(ropes.size()):
		var r: Dictionary = ropes[i]
		r["length"] = min(r["length"] + 200.0 * delta, r["max_length"])
		r["life"] -= delta
		if r["life"] <= 0.0:
			expired.append(i)
			continue
		if not r["hit"]:
			var tip = r["start"] + r["dir"] * r["length"]
			for p in get_tree().get_nodes_in_group("players"):
				if tip.distance_to(p.global_position) < 22.0:
					p.take_damage(attack_damage - 5, r["dir"] * 50.0)
					r["hit"] = true
	for i in expired:
		ropes.remove_at(i)
	if not ropes.is_empty():
		queue_redraw()

func _start_charge() -> void:
	if not target:
		return
	is_charging = true
	charge_velocity = (target.global_position - global_position).normalized() * 240.0
	GameManager.trigger_screen_shake(4.0, 0.2)

func _check_charge_hit() -> void:
	for p in get_tree().get_nodes_in_group("players"):
		if global_position.distance_to(p.global_position) < 40.0:
			p.take_damage(22, charge_velocity.normalized() * 80.0)

func _stomp() -> void:
	GameManager.trigger_screen_shake(7.0, 0.4)
	# Stomp shockwave: anyone on ground near boss takes damage
	for p in get_tree().get_nodes_in_group("players"):
		if global_position.distance_to(p.global_position) < 70.0 and p.jump_offset == 0.0:
			p.take_damage(15, Vector2.ZERO)

func _draw_enemy() -> void:
	var fx: int = 1 if facing_right else -1
	# Giant — 1.5x normal enemy size
	var face_col := Color(0.75 + face_redness * 0.2, 0.35 - face_redness * 0.15, 0.25 - face_redness * 0.1)
	var suit := Color(0.12, 0.12, 0.16)  # bouncer black

	# Huge legs
	draw_rect(Rect2(-14, -22, 11, 22), suit)
	draw_rect(Rect2(3, -22, 11, 22), suit)
	draw_rect(Rect2(-16, -5, 13, 6), Color(0.1, 0.08, 0.06))
	draw_rect(Rect2(3, -5, 13, 6), Color(0.1, 0.08, 0.06))

	# Massive body
	draw_rect(Rect2(-18, -54, 36, 32), suit)
	# Bow tie (bouncer)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-6, -42), Vector2(0, -38), Vector2(6, -42),
							Vector2(0, -46), Vector2(-6, -42)]),
		Color(0.7, 0.1, 0.1)
	)

	# Giant head (red-faced)
	draw_circle(Vector2(0, -66), 18.0, face_col)
	# Tiny eyes, big eyebrows
	draw_circle(Vector2(-6, -68), 3.0, Color(0.1, 0.05, 0.05))
	draw_circle(Vector2(6, -68), 3.0, Color(0.1, 0.05, 0.05))
	draw_rect(Rect2(-9, -74, 8, 3), Color(0.2, 0.05, 0.05))
	draw_rect(Rect2(1, -74, 8, 3), Color(0.2, 0.05, 0.05))
	# Sneer
	draw_arc(Vector2(0, -60), 7.0, PI + 0.3, TAU - 0.3, 12, Color(0.2, 0.05, 0.05), 2.0)

	# Arms
	draw_rect(Rect2(-30, -54, 12, 30), suit)
	draw_rect(Rect2(18, -54, 12, 30), suit)

	# Velvet rope whips
	for r in ropes:
		var local_start = to_local(r["start"])
		var end = local_start + r["dir"] * r["length"]
		draw_line(local_start, end, Color(0.6, 0.1, 0.4), 3.5)
		draw_circle(end, 4.0, Color(0.7, 0.15, 0.5))

	# HP bar
	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-30, -90, 60, 5), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-30, -90, 60 * hp_ratio, 5), Color(0.9, 0.15, 0.15))

	if transitioning:
		draw_arc(Vector2(0, -66), 22.0, 0, TAU, 32, Color(1.0, 0.5, 0.0, 0.7), 3.0)

	if state == State.STUNNED:
		for i in range(4):
			var a := Time.get_ticks_msec() * 0.003 + i * TAU / 4.0
			draw_circle(Vector2(cos(a) * 20, sin(a) * 8 - 80), 4.0, Color(1.0, 1.0, 0.0))
