## Stage 2 enemy — faceless data-drone on a black moped.
## Attacks in formation; fast and swarmy.
class_name StreamingDrone
extends Enemy

var formation_offset: Vector2 = Vector2.ZERO  # set by stage spawner
var moped_wobble: float = 0.0

func _ready() -> void:
	max_health = 40
	move_speed = 110.0   # fast
	attack_damage = 10
	attack_range = 28.0
	attack_cooldown = 2.2
	score_value = 120
	enemy_color = Color(0.12, 0.12, 0.12)  # matte black
	super._ready()

func _state_approach(delta: float) -> void:
	# Formation-aware approach: try to stay in offset relative to other drones
	if not target or not is_instance_valid(target):
		_find_target()
		return

	var desired := target.global_position + formation_offset
	var diff := desired - global_position
	var dist := global_position.distance_to(target.global_position)

	if dist <= attack_range:
		if attack_timer <= 0.0:
			state = State.ATTACK
		else:
			velocity = Vector2.ZERO
		return

	var dir := diff.normalized()
	dir.y *= 0.5
	velocity = dir * move_speed
	facing_right = diff.x > 0
	moped_wobble += delta * 8.0

func _draw_enemy() -> void:
	var fx: int = 1 if facing_right else -1
	var wobble: float = sin(moped_wobble) * 2.0

	# Moped body
	var moped_col := Color(0.08, 0.08, 0.08)
	draw_rect(Rect2(-14, -8, 28, 8), moped_col)
	draw_rect(Rect2(-12, -14, 8, 6), moped_col)    # handlebars
	draw_rect(Rect2(fx * 4, -16, fx * 6, 4), Color(0.6, 0.1, 0.1))  # fairing

	# Wheels
	draw_arc(Vector2(-10, 0), 8.0, 0, TAU, 16, Color(0.3, 0.3, 0.3), 3.0)
	draw_arc(Vector2(10, 0), 8.0, 0, TAU, 16, Color(0.3, 0.3, 0.3), 3.0)
	draw_circle(Vector2(-10, 0), 3.0, Color(0.5, 0.5, 0.5))
	draw_circle(Vector2(10, 0), 3.0, Color(0.5, 0.5, 0.5))

	# Rider — faceless black figure
	draw_rect(Rect2(-6, -28 + wobble, 12, 20), Color(0.06, 0.06, 0.06))
	draw_circle(Vector2(0, -34 + wobble), 8.0, Color(0.06, 0.06, 0.06))
	# Blank visor (no face — they ARE the algorithm)
	draw_rect(Rect2(-5, -37 + wobble, 10, 5), Color(0.2, 0.5, 0.8, 0.7))

	# Exhaust data stream
	if state == State.APPROACH:
		for i in range(3):
			var ex := Vector2(-fx * (12 + i * 8), -4 - i * 2 + wobble)
			draw_circle(ex, 2.5 - i * 0.6, Color(0.3, 0.8, 0.9, 0.6 - i * 0.18))

	# Health bar
	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-12, -48, 24, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-12, -48, 24 * hp_ratio, 3), Color(0.2, 0.6, 0.9))

	if state == State.STUNNED:
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			draw_circle(Vector2(cos(a) * 14, sin(a) * 6 - 50), 3.0, Color(1.0, 1.0, 0.0))
