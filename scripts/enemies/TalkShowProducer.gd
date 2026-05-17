## Stage 4 enemy — talk show producer with mic and speech bubble projectiles.
class_name TalkShowProducer
extends Enemy

var speech_bubbles: Array[Dictionary] = []
var mic_cooldown: float = 0.0

func _ready() -> void:
	max_health = 58
	move_speed = 62.0
	attack_damage = 9
	attack_range = 32.0
	attack_cooldown = 1.8
	score_value = 110
	enemy_color = Color(0.25, 0.35, 0.55)  # TV blue suit
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	mic_cooldown -= delta
	if state == State.APPROACH and target and mic_cooldown <= 0.0:
		var dist := global_position.distance_to(target.global_position)
		if dist < 180.0:
			_spawn_speech_bubble()
			mic_cooldown = 4.0
	_update_bubbles(delta)

func _spawn_speech_bubble() -> void:
	# Speech bubbles float toward players and must be punched
	var dir := Vector2(randf_range(-1, 1), randf_range(-0.5, -0.2)).normalized()
	var text_options := ["CONTENT!", "ENGAGEMENT!", "METRICS!", "REACH!", "SYNERGY!"]
	speech_bubbles.append({
		"pos": Vector2(global_position),
		"vel": dir * 70.0,
		"life": 3.5,
		"text": text_options[randi() % text_options.size()],
		"hp": 1,
	})

func _update_bubbles(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(speech_bubbles.size()):
		var b: Dictionary = speech_bubbles[i]
		b["pos"] += b["vel"] * delta
		b["life"] -= delta
		b["vel"] = b["vel"].lerp(Vector2.ZERO, delta * 0.8)  # drift and slow
		if b["life"] <= 0.0 or b["hp"] <= 0:
			expired.append(i)
			continue
		# Damage players on contact
		for p in get_tree().get_nodes_in_group("players"):
			if b["pos"].distance_to(p.global_position) < 20.0:
				p.take_damage(7, Vector2.ZERO)
				b["hp"] = 0
		# Can be punched by player attacks (check via proximity to attack hitbox)
		for p in get_tree().get_nodes_in_group("players"):
			if p.state in [Player.State.ATTACK1, Player.State.ATTACK2, Player.State.ATTACK3]:
				var box := p._get_attack_hitbox()
				if box.has_point(b["pos"]):
					b["hp"] = 0
					p._gain_special(4.0)
					GameManager.add_score(20)
	for i in expired:
		speech_bubbles.remove_at(i)
	if not speech_bubbles.is_empty():
		queue_redraw()

func _draw_enemy() -> void:
	var fx := 1 if facing_right else -1
	var skin := Color(0.85, 0.72, 0.60)
	var suit := enemy_color

	draw_rect(Rect2(-8, -14, 6, 14), suit)
	draw_rect(Rect2(2, -14, 6, 14), suit)
	draw_rect(Rect2(-9, -4, 8, 4), Color(0.18, 0.14, 0.10))
	draw_rect(Rect2(2, -4, 8, 4), Color(0.18, 0.14, 0.10))
	draw_rect(Rect2(-10, -32, 20, 18), suit)
	# Tie
	draw_rect(Rect2(-2, -32, 4, 14), Color(0.7, 0.1, 0.1))
	draw_circle(Vector2(0, -41), 9.0, skin)
	draw_circle(Vector2(fx * 3, -42), 1.5, Color(0.15, 0.10, 0.10))
	# Microphone
	draw_line(Vector2(fx * 10, -30), Vector2(fx * 16, -22), Color(0.6, 0.6, 0.6), 2.5)
	draw_circle(Vector2(fx * 16, -22), 4.5, Color(0.4, 0.4, 0.4))

	# Floating speech bubbles
	for b in speech_bubbles:
		var lp := to_local(b["pos"])
		draw_rect(Rect2(lp.x - 18, lp.y - 10, 36, 20), Color(1.0, 1.0, 1.0, 0.9))
		draw_arc(lp, 18.0, 0, TAU, 24, Color(0.6, 0.6, 0.6), 1.5)
		# Tail
		draw_line(lp + Vector2(-5, 10), Vector2(lp.x - 12, lp.y + 18), Color(1.0, 1.0, 1.0, 0.9), 3.0)

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-12, -58, 24, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-12, -58, 24 * hp_ratio, 3), Color(0.9, 0.2, 0.2))

	if state == State.STUNNED:
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			draw_circle(Vector2(cos(a) * 14, sin(a) * 6 - 60), 3.0, Color(1.0, 1.0, 0.0))
