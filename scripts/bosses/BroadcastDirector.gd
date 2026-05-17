## STAGE 4 BOSS — The Broadcast Director
## Enormous figure with camera drones and a live ratings ticker as HP display.
## Defeating him = Khn hands a hot dog to a cameraman, breaking the signal.
class_name BroadcastDirector
extends Boss

var camera_drones: Array[Dictionary] = []
var drone_timer: float = 0.0
var shield_active: bool = false
var shield_timer: float = 0.0
var ratings_hp_display: float = 1.0  # lerped visual
var ratings_text_scroll: float = 0.0

func _ready() -> void:
	max_health = 420
	move_speed = 40.0
	attack_damage = 18
	attack_range = 45.0
	attack_cooldown = 2.2
	score_value = 1300
	phase_thresholds = [0.6, 0.3]
	max_phases = 3
	enemy_color = Color(0.22, 0.25, 0.35)
	super._ready()

func _on_phase_enter(phase: int) -> void:
	match phase:
		2:
			shield_active = true
			shield_timer = 5.0
			move_speed = 55.0
		3:
			attack_damage = 25
			drone_timer = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	drone_timer -= delta
	ratings_text_scroll += delta * 60.0
	ratings_hp_display = lerp(ratings_hp_display, float(health) / float(max_health), delta * 2.0)

	if shield_timer > 0.0:
		shield_timer -= delta
		if shield_timer <= 0.0:
			shield_active = false

	if drone_timer <= 0.0:
		_spawn_drone()
		drone_timer = 2.5 if current_phase < 3 else 1.5

	_update_drones(delta)

func _spawn_drone() -> void:
	var angle := randf() * TAU
	var offset := Vector2(cos(angle), sin(angle) * 0.4) * 100.0
	camera_drones.append({
		"pos": global_position + offset,
		"target_angle": angle,
		"orbit_speed": randf_range(1.5, 2.5) * (1 if randf() > 0.5 else -1),
		"life": 6.0,
		"firing": false,
		"fire_timer": randf_range(1.5, 3.0),
		"projectile": null,
	})

func _update_drones(delta: float) -> void:
	var expired: Array[int] = []
	for i in range(camera_drones.size()):
		var d: Dictionary = camera_drones[i]
		d["target_angle"] += d["orbit_speed"] * delta
		var orbit_r := 90.0
		d["pos"] = global_position + Vector2(
			cos(d["target_angle"]) * orbit_r,
			sin(d["target_angle"]) * orbit_r * 0.4
		)
		d["life"] -= delta
		d["fire_timer"] -= delta
		if d["fire_timer"] <= 0.0 and not d["firing"]:
			d["firing"] = true
			_fire_drone_shot(d["pos"])
			d["fire_timer"] = randf_range(2.0, 4.0)
			d["firing"] = false
		if d["life"] <= 0.0:
			expired.append(i)
	for i in expired:
		camera_drones.remove_at(i)
	if not camera_drones.is_empty():
		queue_redraw()

func _fire_drone_shot(from_pos: Vector2) -> void:
	# Find nearest player
	var nearest: Node2D = null
	var nearest_dist := INF
	for p in get_tree().get_nodes_in_group("players"):
		var d := from_pos.distance_to(p.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = p
	if not nearest:
		return
	# Instant hit if in range (simulated laser)
	if nearest_dist < 40.0:
		nearest.take_damage(14, Vector2.ZERO)
		GameManager.trigger_screen_shake(2.0, 0.1)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if shield_active:
		GameManager.trigger_screen_shake(1.5, 0.07)
		return
	super.take_damage(amount, knockback)

func _draw_enemy() -> void:
	var suit := enemy_color
	var skin := Color(0.80, 0.68, 0.58)
	var fx := 1 if facing_right else -1

	# Very large director figure
	draw_rect(Rect2(-14, -24, 11, 24), suit)
	draw_rect(Rect2(3, -24, 11, 24), suit)
	draw_rect(Rect2(-15, -5, 12, 5), Color(0.1, 0.08, 0.06))
	draw_rect(Rect2(3, -5, 12, 5), Color(0.1, 0.08, 0.06))
	draw_rect(Rect2(-16, -56, 32, 32), suit)
	# Director's vest
	draw_rect(Rect2(-8, -54, 16, 26), Color(0.35, 0.30, 0.25))
	draw_circle(Vector2(0, -62), 16.0, skin)
	# Headset
	draw_arc(Vector2(0, -72), 14.0, -PI, 0, 12, Color(0.3, 0.3, 0.3), 3.0)
	draw_circle(Vector2(-14, -72), 4.0, Color(0.3, 0.3, 0.3))
	draw_circle(Vector2(14, -72), 4.0, Color(0.3, 0.3, 0.3))

	# Ratings ticker (live HP display along bottom of boss)
	var ticker_w := 80.0
	draw_rect(Rect2(-40, -12, ticker_w, 8), Color(0.1, 0.1, 0.2))
	# Scrolling text approximation (lines of varying width)
	var scroll_x := fmod(ratings_text_scroll, 100) - 50
	draw_rect(Rect2(-36 + scroll_x, -11, 40 * ratings_hp_display, 3),
		Color(0.1, 0.9, 0.1) if ratings_hp_display > 0.3 else Color(0.9, 0.2, 0.1))

	# Shield
	if shield_active:
		var shield_alpha := min(shield_timer / 2.0, 1.0) * 0.5
		draw_arc(Vector2(0, -32), 40.0, 0, TAU, 32, Color(0.4, 0.6, 1.0, shield_alpha), 4.0)

	# Camera drones
	for d in camera_drones:
		var lp := to_local(d["pos"])
		draw_rect(Rect2(lp.x - 7, lp.y - 5, 14, 10), Color(0.25, 0.25, 0.3))
		draw_circle(lp + Vector2(0, -1), 4.0, Color(0.15, 0.15, 0.2))
		draw_circle(lp + Vector2(0, -1), 2.5, Color(0.1, 0.2, 0.6))
		# Lens glint
		draw_circle(lp + Vector2(-1, -2), 0.8, Color(1.0, 1.0, 1.0, 0.7))
		# Orbit tether
		draw_line(Vector2(0, -32), lp, Color(0.2, 0.3, 0.5, 0.3), 1.0)

	var hp_ratio := float(health) / float(max_health)
	draw_rect(Rect2(-35, -92, 70, 5), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-35, -92, 70 * hp_ratio, 5), Color(0.1, 0.8, 0.1))

	if transitioning:
		draw_arc(Vector2(0, -62), 22.0, 0, TAU, 32, Color(1.0, 0.5, 0.0, 0.7), 3.0)
