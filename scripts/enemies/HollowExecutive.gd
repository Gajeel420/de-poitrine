## Stage 6 enemy — colonized by SPEC-13 signal; fights in perfect, inhuman sync.
## More dangerous than earlier enemies because their emptiness IS the threat.
class_name HollowExecutive
extends Enemy

# All HollowExecutives share a sync clock
static var sync_clock: float = 0.0
static var sync_phase: int = 0  # 0=approach, 1=attack, 2=retreat

var sync_offset: float = 0.0  # per-unit phase offset (tiny, for visual variation)
var eyes_glow_timer: float = 0.0

func _ready() -> void:
	max_health = 80
	move_speed = 78.0
	attack_damage = 13
	attack_range = 30.0
	attack_cooldown = 1.5
	score_value = 150
	enemy_color = Color(0.15, 0.15, 0.20)  # near-black corporate
	super._ready()

func _physics_process(delta: float) -> void:
	# Update shared sync clock
	HollowExecutive.sync_clock += delta
	eyes_glow_timer += delta

	# Override state based on sync phase
	if state not in [State.DEAD, State.HURT, State.STUNNED]:
		var cycle := fmod(HollowExecutive.sync_clock + sync_offset, 3.5)
		if cycle < 2.0:
			if state != State.APPROACH:
				state = State.APPROACH
		elif cycle < 2.6:
			if attack_timer <= 0.0 and state != State.ATTACK:
				state = State.ATTACK
		else:
			# Brief synchronized retreat
			if target:
				var diff := global_position - target.global_position
				velocity = diff.normalized() * move_speed * 0.5
				state = State.IDLE

	super._physics_process(delta)

func _draw_enemy() -> void:
	var fx := 1 if facing_right else -1
	var suit := enemy_color
	var void_color := Color(0.0, 0.0, 0.05)  # almost nothing inside

	# Perfect, symmetrical suit
	draw_rect(Rect2(-8, -14, 7, 14), suit)
	draw_rect(Rect2(2, -14, 7, 14), suit)
	draw_rect(Rect2(-10, -4, 9, 4), Color(0.05, 0.05, 0.06))
	draw_rect(Rect2(2, -4, 9, 4), Color(0.05, 0.05, 0.06))
	draw_rect(Rect2(-10, -34, 20, 20), suit)
	# Perfect white shirt / tie
	draw_rect(Rect2(-3, -32, 6, 14), Color(0.95, 0.95, 0.95, 0.6))
	draw_rect(Rect2(-1, -32, 3, 10), Color(0.25, 0.25, 0.35))

	# Head — almost featureless
	draw_circle(Vector2(0, -43), 10.0, Color(0.18, 0.18, 0.22))

	# Eyes: SPEC-13 signal glow (pulsing blue triangles)
	var glow_alpha := (sin(eyes_glow_timer * 3.0 + sync_offset) * 0.4 + 0.6)
	var eye_col := Color(0.3, 0.5, 1.0, glow_alpha)
	# Left eye (triangle)
	var le := Vector2(fx * -4, -44.0)
	draw_colored_polygon(PackedVector2Array([le + Vector2(-3, 3), le + Vector2(0, -3), le + Vector2(3, 3)]), eye_col)
	# Right eye (triangle)
	var re := Vector2(fx * 4, -44.0)
	draw_colored_polygon(PackedVector2Array([re + Vector2(-3, 3), re + Vector2(0, -3), re + Vector2(3, 3)]), eye_col)

	# SPEC-13 logo on chest (inverted triangle)
	var cx := 0.0; var cy := -26.0
	draw_colored_polygon(
		PackedVector2Array([Vector2(cx, cy + 6), Vector2(cx - 5, cy - 2), Vector2(cx + 5, cy - 2)]),
		Color(0.3, 0.5, 1.0, 0.7)
	)

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-12, -60, 24, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-12, -60, 24 * hp_ratio, 3), Color(0.3, 0.5, 1.0))

	if state == State.STUNNED:
		# ODD METER breaks the sync — they actually look relieved for a moment
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			draw_circle(Vector2(cos(a) * 14, sin(a) * 6 - 62), 3.0, Color(1.0, 1.0, 0.0))
