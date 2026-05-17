## Base enemy class — state machine AI for all SPEC-13 goons.
class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)

# --- Stats (override in subclasses) ---
@export var max_health: int = 60
@export var move_speed: float = 70.0
@export var attack_damage: int = 10
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.8
@export var score_value: int = 100
@export var enemy_color: Color = Color(0.35, 0.35, 0.45)

# --- State machine ---
enum State { IDLE, PATROL, APPROACH, ATTACK, HURT, DEAD, STUNNED }
var state: State = State.IDLE

var health: int
var target: Node2D = null      # current player target
var attack_timer: float = 0.0
var hurt_timer: float = 0.0
var stunned_timer: float = 0.0  # ODD METER effect

# --- Animation ---
var anim_frame: int = 0
var anim_timer: float = 0.0
const ANIM_FPS: float = 6.0

# --- Misc ---
var facing_right: bool = false
var spawn_x: float = 0.0

# Floor bounds (same as player)
const FLOOR_Y_MIN: float = 230.0
const FLOOR_Y_MAX: float = 310.0

func _ready() -> void:
	health = max_health
	spawn_x = global_position.x
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 1  # world
	_find_target()

func _find_target() -> void:
	var players := get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return
	var closest_dist := INF
	for p in players:
		var d := global_position.distance_to(p.global_position)
		if d < closest_dist:
			closest_dist = d
			target = p

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_update_timers(delta)
	_update_animation(delta)

	match state:
		State.IDLE, State.PATROL:
			_state_patrol(delta)
		State.APPROACH:
			_state_approach(delta)
		State.ATTACK:
			_state_attack(delta)
		State.STUNNED:
			velocity = velocity.lerp(Vector2.ZERO, delta * 4.0)

	move_and_slide()
	position.y = clamp(position.y, FLOOR_Y_MIN, FLOOR_Y_MAX)
	z_index = int(position.y) - 220
	queue_redraw()

func _update_timers(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
	if hurt_timer > 0.0:
		hurt_timer -= delta
		if hurt_timer <= 0.0 and state == State.HURT:
			state = State.APPROACH
	if stunned_timer > 0.0:
		stunned_timer -= delta
		if stunned_timer <= 0.0 and state == State.STUNNED:
			state = State.APPROACH

func _update_animation(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= 1.0 / ANIM_FPS:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % 8

# ──────────────────────────────────────────────
#  AI STATES
# ──────────────────────────────────────────────

func _state_patrol(_delta: float) -> void:
	if target and target.is_in_group("players"):
		var dist := global_position.distance_to(target.global_position)
		if dist < 280.0:
			state = State.APPROACH
			return
	velocity = Vector2.ZERO

func _state_approach(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_find_target()
		return
	var diff := target.global_position - global_position
	var dist := diff.length()

	if dist <= attack_range:
		if attack_timer <= 0.0:
			state = State.ATTACK
		else:
			velocity = Vector2.ZERO
		return

	var dir := diff.normalized()
	# Y movement is compressed (depth illusion)
	dir.y *= 0.5
	velocity = dir * move_speed
	facing_right = diff.x > 0

func _state_attack(_delta: float) -> void:
	velocity = Vector2.ZERO
	if attack_timer <= 0.0:
		_do_attack()
		attack_timer = attack_cooldown
		await get_tree().create_timer(0.35).timeout
		if state == State.ATTACK:
			state = State.APPROACH

func _do_attack() -> void:
	if not target or not is_instance_valid(target):
		return
	if global_position.distance_to(target.global_position) <= attack_range + 8:
		target.take_damage(attack_damage, Vector2((1 if facing_right else -1) * 50.0, 0))

# ──────────────────────────────────────────────
#  DAMAGE / DEATH
# ──────────────────────────────────────────────

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return
	health -= amount
	health = max(health, 0)
	velocity = knockback
	if health <= 0:
		_die()
		return
	state = State.HURT
	hurt_timer = 0.3
	_find_target()

func enter_odd_meter(duration: float) -> void:
	# Called by KLEK's ODD METER special
	state = State.STUNNED
	stunned_timer = duration
	velocity = Vector2(randf_range(-40, 40), randf_range(-20, 20))

func _die() -> void:
	state = State.DEAD
	GameManager.add_score(score_value)
	remove_from_group("enemies")
	died.emit(self)
	# Death animation: fall and fade
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.tween_callback(queue_free)

# ──────────────────────────────────────────────
#  DRAWING  (override _draw_enemy in subclasses)
# ──────────────────────────────────────────────

func _draw() -> void:
	if state == State.DEAD:
		return
	var flash := (state == State.HURT) and (int(Time.get_ticks_msec() / 60) % 2 == 0)
	if flash:
		return
	_draw_shadow()
	_draw_enemy()

func _draw_shadow() -> void:
	draw_arc(Vector2(0, 0), 9.0, 0, TAU, 16, Color(0, 0, 0, 0.3), 3.0)

func _draw_enemy() -> void:
	# Default: suit-wearing goon
	var suit := enemy_color
	var skin := Color(0.85, 0.72, 0.60)
	var shoe := Color(0.15, 0.12, 0.08)
	var fx := 1 if facing_right else -1

	# Legs
	draw_rect(Rect2(-8, -14, 6, 14), suit)
	draw_rect(Rect2(2, -14, 6, 14), suit)
	draw_rect(Rect2(-10, -4, 8, 4), shoe)
	draw_rect(Rect2(2, -4, 8, 4), shoe)

	# Body
	draw_rect(Rect2(-9, -32, 18, 18), suit)

	# Head
	draw_circle(Vector2(0, -40), 9.0, skin)

	# Eyes (beady, corporate)
	draw_circle(Vector2(fx * 3, -41), 1.5, Color(0.1, 0.1, 0.1))

	# Health bar (above head)
	var hp_ratio := float(health) / float(max_health)
	var bar_w := 24.0
	draw_rect(Rect2(-bar_w / 2, -56, bar_w, 3), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-bar_w / 2, -56, bar_w * hp_ratio, 3), Color(0.9, 0.2, 0.2))

	# Stun stars (ODD METER effect)
	if state == State.STUNNED:
		for i in range(3):
			var a := Time.get_ticks_msec() * 0.004 + i * TAU / 3.0
			var sp := Vector2(cos(a) * 14, sin(a) * 6 - 52)
			draw_circle(sp, 3.0, Color(1.0, 1.0, 0.0))
