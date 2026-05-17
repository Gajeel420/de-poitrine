## Base class for KHN and KLEK.
## Belt-scroller movement: node position = floor position, jump_offset shifts visual up.
class_name Player
extends CharacterBody2D

signal died(player_id: int)
signal health_changed(new_hp: int, max_hp: int)
signal special_changed(new_val: float, max_val: float)

# --- Config (overridden by subclasses) ---
@export var player_id: int = 1
@export var max_health: int = 120
@export var move_speed: float = 140.0
@export var attack_damage: int = 12
@export var kick_damage: int = 16
@export var special_damage: int = 35

# --- Floor bounds (world Y coords) ---
const FLOOR_Y_MIN: float = 230.0
const FLOOR_Y_MAX: float = 310.0

# --- State ---
enum State { IDLE, WALK, JUMP, ATTACK1, ATTACK2, ATTACK3, KICK, HURT, DEAD, SPECIAL, GRAB }
var state: State = State.IDLE
var facing_right: bool = true
var health: int
var lives: int = 3
var invincible_timer: float = 0.0

# --- Jump ---
var jump_offset: float = 0.0
var jump_velocity: float = 0.0

# --- Combat ---
var combo_count: int = 0
var combo_timer: float = 0.0
const COMBO_WINDOW: float = 0.6
var attack_timer: float = 0.0
var attack_duration: float = 0.22
var already_hit: Array = []  # enemies hit in this attack swing

# --- Special meter ---
var special_meter: float = 0.0
const MAX_SPECIAL: float = 100.0

# --- Animation ---
var anim_frame: int = 0
var anim_timer: float = 0.0
const ANIM_FPS: float = 8.0

# --- Sprite sheet support ---
var _sprite: AnimatedSprite2D = null  # set by _init_sprite() if sheet found
var _use_sprite: bool = false

# --- Polka dot positions (stable random, set in _ready) ---
var dot_positions: Array[Vector2] = []

# --- Co-op sync bonus ---
var last_attack_frame: int = -999  # Engine.get_process_frames() of last attack

func _ready() -> void:
	health = max_health
	_generate_dots()
	add_to_group("players")
	collision_layer = 1
	collision_mask = 3
	_init_sprite()

func _init_sprite() -> void:
	pass  # Overridden by Khn/Klek to provide character-specific SpriteFrames

func _setup_animated_sprite(sf: SpriteFrames) -> void:
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = sf
	_sprite.position = Vector2(0, -32)  # visual offset: feet at node origin
	_sprite.flip_h = not facing_right
	# Apply chroma-key shader
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = load("res://shaders/chroma_key.gdshader")
	_sprite.material = shader_mat
	add_child(_sprite)
	_sprite.play("idle")
	_use_sprite = true

func _generate_dots() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = player_id * 7919 + 42
	for i in range(10):
		dot_positions.append(Vector2(
			rng.randf_range(-9.0, 9.0),
			rng.randf_range(-30.0, -10.0)
		))

# ──────────────────────────────────────────────
#  MAIN LOOPS
# ──────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_update_timers(delta)
	_handle_jump(delta)

	if state not in [State.HURT, State.ATTACK1, State.ATTACK2, State.ATTACK3,
					  State.KICK, State.SPECIAL, State.GRAB]:
		_handle_movement(delta)
		_handle_input()
	elif state in [State.ATTACK1, State.ATTACK2, State.ATTACK3, State.KICK, State.SPECIAL]:
		_update_attack()

	move_and_slide()
	position.y = clamp(position.y, FLOOR_Y_MIN, FLOOR_Y_MAX)
	z_index = int(position.y) - 220  # depth sort

	_update_animation(delta)
	queue_redraw()

func _update_timers(delta: float) -> void:
	if invincible_timer > 0.0:
		invincible_timer -= delta
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_count = 0

func _handle_jump(delta: float) -> void:
	if jump_offset < 0.0:
		jump_offset += jump_velocity * delta
		jump_velocity -= 480.0 * delta
		if jump_offset >= 0.0:
			jump_offset = 0.0
			jump_velocity = 0.0
			if state == State.JUMP:
				state = State.IDLE

func _handle_movement(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("p%d_left" % player_id):
		dir.x = -1.0; facing_right = false
	elif Input.is_action_pressed("p%d_right" % player_id):
		dir.x = 1.0; facing_right = true
	if Input.is_action_pressed("p%d_up" % player_id):
		dir.y = -0.6
	elif Input.is_action_pressed("p%d_down" % player_id):
		dir.y = 0.6

	if dir != Vector2.ZERO:
		velocity = dir.normalized() * move_speed
		if jump_offset == 0.0:
			state = State.WALK
	else:
		velocity = Vector2.ZERO
		if jump_offset == 0.0 and state == State.WALK:
			state = State.IDLE

func _handle_input() -> void:
	if Input.is_action_just_pressed("p%d_jump" % player_id) and jump_offset == 0.0:
		_start_jump()
	elif Input.is_action_just_pressed("p%d_attack" % player_id):
		_start_attack()
	elif Input.is_action_just_pressed("p%d_kick" % player_id):
		_start_kick()
	elif Input.is_action_just_pressed("p%d_special" % player_id) and special_meter >= MAX_SPECIAL:
		_start_special()

func _start_jump() -> void:
	jump_offset = -1.0
	jump_velocity = -200.0
	state = State.JUMP
	GameManager.trigger_screen_shake(1.0, 0.05)

func _start_attack() -> void:
	combo_timer = COMBO_WINDOW
	combo_count += 1
	already_hit.clear()
	last_attack_frame = Engine.get_process_frames()
	match combo_count:
		1: state = State.ATTACK1
		2: state = State.ATTACK2
		_: state = State.ATTACK3; combo_count = 0
	attack_timer = attack_duration
	velocity = Vector2.ZERO

func _start_kick() -> void:
	already_hit.clear()
	state = State.KICK
	attack_timer = attack_duration * 1.3
	velocity = Vector2((1 if facing_right else -1) * 30.0, 0)

func _start_special() -> void:
	if special_meter < MAX_SPECIAL:
		return
	special_meter = 0.0
	special_changed.emit(special_meter, MAX_SPECIAL)
	_do_special()

func _do_special() -> void:
	# Override in subclass
	pass

func _update_attack() -> void:
	attack_timer -= get_physics_process_delta_time()
	_check_attack_hits()
	if attack_timer <= 0.0:
		state = State.IDLE

func _update_animation(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= 1.0 / ANIM_FPS:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % 8
	if _use_sprite and _sprite:
		_sprite.flip_h = not facing_right
		_sprite.position.y = -32 + jump_offset
		var anim_name := _state_to_anim()
		if _sprite.animation != anim_name:
			_sprite.play(anim_name)

func _state_to_anim() -> String:
	match state:
		State.WALK:   return "walk"
		State.ATTACK1, State.ATTACK2, State.ATTACK3, State.KICK: return "attack"
		State.SPECIAL: return "special"
		State.HURT:   return "hurt"
		State.DEAD:   return "dead"
		_:            return "idle"

# ──────────────────────────────────────────────
#  COMBAT
# ──────────────────────────────────────────────

func _get_attack_hitbox() -> Rect2:
	var reach: float = 36.0 if state == State.ATTACK3 else 28.0
	var ox: float = reach if facing_right else -reach - 20.0
	var oy := jump_offset - 30.0
	return Rect2(position.x + ox, position.y + oy, 20.0, 24.0)

func _get_kick_hitbox() -> Rect2:
	var ox: float = 30.0 if facing_right else -50.0
	return Rect2(position.x + ox, position.y + jump_offset - 22.0, 22.0, 20.0)

func _check_attack_hits() -> void:
	var box: Rect2
	var dmg: int
	if state == State.KICK:
		box = _get_kick_hitbox()
		dmg = kick_damage
	else:
		box = _get_attack_hitbox()
		dmg = attack_damage
		if state == State.ATTACK3:
			dmg = int(attack_damage * 1.4)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if already_hit.has(enemy):
			continue
		var ep: Vector2 = enemy.global_position
		if box.has_point(ep):
			var knockback: Vector2 = Vector2((1 if facing_right else -1) * 60.0, 0)
			enemy.take_damage(dmg, knockback)
			already_hit.append(enemy)
			_gain_special(8.0)
			_check_coop_bonus(enemy, dmg)
			GameManager.add_score(10)
			GameManager.trigger_screen_shake(2.5, 0.08)

func _check_coop_bonus(enemy: Node, dmg: int) -> void:
	# If the other player also attacked this frame → double microtonal damage
	var other_id: int = 2 if player_id == 1 else 1
	for p in get_tree().get_nodes_in_group("players"):
		if p.player_id == other_id:
			var frame_diff: int = int(abs(Engine.get_process_frames() - p.last_attack_frame))
			if frame_diff <= 1:
				enemy.take_damage(dmg, Vector2.ZERO)  # bonus hit
				GameManager.trigger_screen_shake(4.0, 0.12)

func _gain_special(amount: float) -> void:
	special_meter = min(special_meter + amount, MAX_SPECIAL)
	special_changed.emit(special_meter, MAX_SPECIAL)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if invincible_timer > 0.0 or state == State.DEAD:
		return
	health -= amount
	health = max(health, 0)
	health_changed.emit(health, max_health)
	GameManager.trigger_screen_shake(3.0, 0.12)
	if health <= 0:
		_die()
		return
	state = State.HURT
	invincible_timer = 1.2
	velocity = knockback
	await get_tree().create_timer(0.35).timeout
	if state == State.HURT:
		state = State.IDLE
		velocity = Vector2.ZERO

func _die() -> void:
	state = State.DEAD
	lives -= 1
	await get_tree().create_timer(0.8).timeout
	died.emit(player_id)

# ──────────────────────────────────────────────
#  DRAWING  (override _draw_character in subclasses for unique look)
# ──────────────────────────────────────────────

func _draw() -> void:
	var jy := jump_offset
	var flash := (invincible_timer > 0.0) and (int(Time.get_ticks_msec() / 80) % 2 == 0)
	if _use_sprite:
		_sprite.visible = not flash
		_draw_shadow()
		return  # sprite handles the character visuals
	if flash:
		return
	_draw_shadow()
	_draw_character(jy)

func _draw_shadow() -> void:
	var alpha := clamp(1.0 + jump_offset / 80.0, 0.1, 0.5)
	_draw_shadow_ellipse(Vector2(0, 0), Vector2(11, 4), 0, TAU, Color(0, 0, 0, alpha))

func _draw_character(jy: float) -> void:
	# Base implementation: polka-dot suit humanoid
	var suit := Color(0.08, 0.08, 0.08)
	var skin := Color(0.88, 0.78, 0.65)
	var shoe := Color(0.25, 0.18, 0.10)
	var dot  := Color(1.0, 1.0, 1.0)

	var fx: int = 1 if facing_right else -1

	# Legs (animated walk cycle)
	var swing: float = sin(anim_frame * TAU / 8.0) * 4.0
	if state == State.WALK:
		draw_rect(Rect2(fx * -9 - 7, jy - 16, 7, 16), suit)
		draw_rect(Rect2(fx * 2, jy - 16 + swing, 7, 16), suit)
	else:
		draw_rect(Rect2(-9, jy - 16, 7, 16), suit)
		draw_rect(Rect2(2, jy - 16, 7, 16), suit)

	# Shoes
	draw_rect(Rect2(-11, jy - 5, 9, 5), shoe)
	draw_rect(Rect2(2, jy - 5, 9, 5), shoe)

	# Body
	draw_rect(Rect2(-10, jy - 36, 20, 20), suit)

	# Polka dots on body
	for dp in dot_positions:
		draw_circle(Vector2(dp.x, dp.y + jy), 2.0, dot)

	# Head
	draw_circle(Vector2(0, jy - 44), 10.0, skin)

	# Eyes
	var eye_x := fx * 4
	draw_circle(Vector2(eye_x, jy - 45), 2.0, Color(0.1, 0.1, 0.1))

	# Papier-mâché nose
	var nose_end := Vector2(fx * 14, jy - 41)
	draw_line(Vector2(fx * 4, jy - 43), nose_end, Color(0.72, 0.52, 0.32), 2.5)

	# Arms (attack animation)
	_draw_arms(jy, fx)

func _draw_arms(jy: float, fx: int) -> void:
	var arm_y := jy - 28.0
	var arm_swing := 0.0
	if state in [State.ATTACK1, State.ATTACK2, State.ATTACK3]:
		arm_swing = 14.0 * (1.0 - attack_timer / attack_duration)
	elif state == State.KICK:
		arm_swing = -6.0
	# Left arm
	draw_line(Vector2(-10, arm_y), Vector2(-18 - arm_swing * 0.3, arm_y + 8), Color(0.08, 0.08, 0.08), 4)
	# Right arm (attack direction)
	draw_line(Vector2(10, arm_y), Vector2(18 + arm_swing * fx, arm_y + 4), Color(0.08, 0.08, 0.08), 4)

func _draw_shadow_ellipse(center: Vector2, radii: Vector2, angle_from: float,
		angle_to: float, color: Color) -> void:
	var nb_points := 24
	var points_arc := PackedVector2Array()
	for i in range(nb_points + 1):
		var angle_point := angle_from + (angle_to - angle_from) * i / nb_points
		points_arc.append(center + Vector2(cos(angle_point) * radii.x, sin(angle_point) * radii.y))
	for i in range(nb_points):
		draw_line(points_arc[i], points_arc[i + 1], color, 1.0)
