## Stage 3 enemy — imposter in a cheap knockoff polka-dot suit.
## Mirrors player animation to confuse; distinctive "wrong" dot pattern.
class_name FestivalInfiltrator
extends Enemy

var mirror_target_is_khn: bool = true  # which player they're imitating

func _ready() -> void:
	max_health = 65
	move_speed = 80.0
	attack_damage = 11
	attack_range = 34.0
	attack_cooldown = 1.4
	score_value = 130
	enemy_color = Color(0.7, 0.7, 0.7)  # faded, cheap suit
	super._ready()

func _find_target() -> void:
	super._find_target()
	if target:
		mirror_target_is_khn = target.is_in_group("players") and target.player_id == 1

func _draw_enemy() -> void:
	var fx := 1 if facing_right else -1
	var skin := Color(0.85, 0.72, 0.60)
	var shoe := Color(0.20, 0.15, 0.10)

	# Cheap knockoff suit — greyish, dots slightly off-pattern
	var suit := Color(0.72, 0.72, 0.72)

	# Legs
	draw_rect(Rect2(-8, -14, 6, 14), suit)
	draw_rect(Rect2(2, -14, 6, 14), suit)
	draw_rect(Rect2(-10, -4, 8, 4), shoe)
	draw_rect(Rect2(2, -4, 8, 4), shoe)

	# Body
	draw_rect(Rect2(-9, -32, 18, 18), suit)

	# Wrong polka dots — too big, wrongly spaced (the algorithm can't get it right)
	var wrong_dots := [
		Vector2(-6, -28), Vector2(3, -22), Vector2(-3, -16),
		Vector2(6, -30), Vector2(-7, -18), Vector2(2, -13),
	]
	for dp in wrong_dots:
		draw_circle(dp, 3.5, Color(0.9, 0.9, 0.9))  # off-white, too big

	# Head
	draw_circle(Vector2(0, -40), 9.0, skin)
	draw_circle(Vector2(fx * 3, -41), 1.5, Color(0.1, 0.1, 0.1))

	# Nose — too short, clearly artificial
	draw_line(Vector2(fx * 3, -41), Vector2(fx * 8, -39), Color(0.85, 0.70, 0.55), 2.0)

	# Fake guitar (for KHN imitation) or fake drumstick (for KLEK)
	if mirror_target_is_khn:
		draw_rect(Rect2(fx * 12, -30, fx * 6, 14), Color(0.4, 0.15, 0.06))
		draw_rect(Rect2(fx * 14, -44, fx * 3, 16), Color(0.55, 0.38, 0.16))
	else:
		draw_line(Vector2(8, -28), Vector2(20, -14), Color(0.55, 0.35, 0.12), 3.0)
		draw_line(Vector2(-4, -28), Vector2(-14, -14), Color(0.55, 0.35, 0.12), 3.0)

	# "SPEC-13" badge on lapel
	draw_rect(Rect2(fx * -2, -30, 8, 5), Color(0.1, 0.1, 0.8))
	draw_rect(Rect2(fx * -1, -29, 6, 3), Color(0.9, 0.9, 0.9, 0.5))

	# Health bar
	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-12, -56, 24, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-12, -56, 24 * hp_ratio, 3), Color(0.9, 0.2, 0.2))

	if state == State.STUNNED:
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			draw_circle(Vector2(cos(a) * 14, sin(a) * 6 - 58), 3.0, Color(1.0, 1.0, 0.0))
