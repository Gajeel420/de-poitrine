## Stage 5 enemy — wealthy collector trying to snatch KHN's guitar.
## Slow but very tanky; grabs KHN specifically if in range.
class_name Speculator
extends Enemy

var grab_timer: float = 0.0
var is_grabbing: bool = false
var grab_target: Node2D = null

func _ready() -> void:
	max_health = 95
	move_speed = 52.0   # slow, deliberate
	attack_damage = 14
	attack_range = 28.0
	attack_cooldown = 2.6
	score_value = 180
	enemy_color = Color(0.28, 0.22, 0.38)  # expensive dark coat
	super._ready()

func _find_target() -> void:
	# Preferentially target KHN (the one with the guitar)
	for p in get_tree().get_nodes_in_group("players"):
		if p.player_id == 1:  # KHN
			target = p
			return
	super._find_target()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	grab_timer -= delta
	if is_grabbing and grab_target:
		if not is_instance_valid(grab_target) or grab_target.state == Player.State.DEAD:
			is_grabbing = false
			return
		# Hold position next to target
		position = position.lerp(grab_target.global_position + Vector2(20, 0), delta * 6.0)
		grab_timer -= delta
		if grab_timer <= 0.0:
			is_grabbing = false
			grab_target = null

func _do_attack() -> void:
	if not target or not is_instance_valid(target):
		return
	if global_position.distance_to(target.global_position) > attack_range + 8:
		return

	if grab_timer <= 0.0 and target.player_id == 1 and not is_grabbing:
		# Attempt guitar grab — briefly pins KHN
		is_grabbing = true
		grab_target = target
		grab_timer = 1.8
		target.take_damage(8, Vector2.ZERO)
		target.state = Player.State.HURT  # interrupts player
	else:
		target.take_damage(attack_damage, Vector2((1 if facing_right else -1) * 40.0, 0))

func _draw_enemy() -> void:
	var fx: int = 1 if facing_right else -1
	var skin := Color(0.85, 0.72, 0.60)
	var coat := enemy_color
	var inner := Color(0.80, 0.75, 0.65)  # expensive shirt

	# Expensive long coat
	draw_rect(Rect2(-10, -14, 8, 14), coat)
	draw_rect(Rect2(2, -14, 8, 14), coat)
	draw_rect(Rect2(-11, -4, 10, 4), Color(0.15, 0.12, 0.08))  # oxford shoes
	draw_rect(Rect2(2, -4, 10, 4), Color(0.15, 0.12, 0.08))
	draw_rect(Rect2(-11, -38, 22, 24), coat)
	# Coat lapels
	draw_rect(Rect2(-8, -36, 6, 16), inner)
	draw_rect(Rect2(2, -36, 6, 16), inner)

	# Head — smug
	draw_circle(Vector2(0, -46), 10.0, skin)
	draw_circle(Vector2(fx * 4, -46), 2.0, Color(0.1, 0.1, 0.1))
	# Smug smirk
	draw_arc(Vector2(0, -42), 5.0, 0.1, PI - 0.1, 8, Color(0.3, 0.2, 0.2), 1.5)

	# Price tag hanging from pocket
	draw_rect(Rect2(fx * 5, -26, 8, 6), Color(0.95, 0.95, 0.80))
	draw_line(Vector2(fx * 9, -28), Vector2(fx * 9, -32), Color(0.5, 0.5, 0.5), 1.0)

	# Grab animation
	if is_grabbing:
		draw_line(Vector2(fx * 10, -30), Vector2(fx * 28, -30), coat, 4.0)
		draw_circle(Vector2(fx * 28, -30), 5.0, coat)

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-12, -64, 24, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-12, -64, 24 * hp_ratio, 3), Color(0.9, 0.2, 0.2))

	if state == State.STUNNED:
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			draw_circle(Vector2(cos(a) * 14, sin(a) * 6 - 66), 3.0, Color(1.0, 1.0, 0.0))
