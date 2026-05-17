## Stage 1 enemy — booking manager in an ill-fitting suit.
## Throws scheduling books and tries to grind players into oblivion.
class_name OverexposureAgent
extends Enemy

var book_throw_timer: float = 0.0
var book_projectiles: Array[Dictionary] = []

func _ready() -> void:
	max_health = 55
	move_speed = 65.0
	attack_damage = 8
	attack_range = 30.0
	attack_cooldown = 1.6
	score_value = 100
	enemy_color = Color(0.38, 0.32, 0.45)  # ill-fitting purple-grey suit
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	book_throw_timer -= delta
	# Throw book at range if player is at medium distance
	if state == State.APPROACH and target and book_throw_timer <= 0.0:
		var dist := global_position.distance_to(target.global_position)
		if dist > 80.0 and dist < 200.0:
			_throw_book()
			book_throw_timer = 3.5
	_update_books(delta)

func _throw_book() -> void:
	if not target:
		return
	var dir := (target.global_position - global_position).normalized()
	book_projectiles.append({
		"pos": Vector2(global_position),
		"vel": dir * 150.0,
		"life": 1.4,
		"hit": false,
	})

func _update_books(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(book_projectiles.size()):
		var b: Dictionary = book_projectiles[i]
		b["pos"] += b["vel"] * delta
		b["life"] -= delta
		if b["life"] <= 0.0:
			expired.append(i)
			continue
		if not b["hit"]:
			for p in get_tree().get_nodes_in_group("players"):
				if b["pos"].distance_to(p.global_position) < 16.0:
					p.take_damage(6, b["vel"].normalized() * 30.0)
					b["hit"] = true
	for i in expired:
		book_projectiles.remove_at(i)
	if not book_projectiles.is_empty():
		queue_redraw()

func _draw_enemy() -> void:
	var suit := enemy_color
	var skin := Color(0.85, 0.72, 0.60)
	var shoe := Color(0.15, 0.12, 0.08)
	var fx := 1 if facing_right else -1

	# Ill-fitting suit (too wide, bunched at shoulders)
	draw_rect(Rect2(-9, -14, 7, 14), suit)
	draw_rect(Rect2(2, -14, 7, 14), suit)
	draw_rect(Rect2(-10, -4, 9, 4), shoe)
	draw_rect(Rect2(2, -4, 9, 4), shoe)
	draw_rect(Rect2(-11, -34, 22, 20), suit)  # wider body
	draw_rect(Rect2(-7, -36, 14, 4), Color(0.9, 0.9, 0.9))  # collar
	draw_circle(Vector2(0, -43), 9.0, skin)
	draw_circle(Vector2(fx * 3, -44), 1.5, Color(0.15, 0.10, 0.10))

	# Scheduling book in hand
	draw_rect(Rect2(fx * 10, -34, fx * 7, 9), Color(0.8, 0.2, 0.1))
	draw_line(Vector2(fx * 10, -31), Vector2(fx * 17, -31), Color(0.1, 0.1, 0.1), 1.0)
	draw_line(Vector2(fx * 10, -28), Vector2(fx * 17, -28), Color(0.1, 0.1, 0.1), 1.0)

	# Thrown books
	for b in book_projectiles:
		var local_pos := to_local(b["pos"])
		draw_rect(Rect2(local_pos.x - 5, local_pos.y - 4, 10, 8), Color(0.8, 0.2, 0.1))

	# Health bar
	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-12, -58, 24, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-12, -58, 24 * hp_ratio, 3), Color(0.9, 0.2, 0.2))

	if state == State.STUNNED:
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			draw_circle(Vector2(cos(a) * 14, sin(a) * 6 - 56), 3.0, Color(1.0, 1.0, 0.0))
