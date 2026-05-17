## Base boss class — phase system, invincibility between phases, boss HP bar.
class_name Boss
extends Enemy

signal phase_changed(new_phase: int)
signal boss_health_changed(hp: int, max_hp: int)

var current_phase: int = 1
var max_phases: int = 2
var phase_thresholds: Array[float] = [0.5]  # HP ratios that trigger next phase
var transitioning: bool = false

func _ready() -> void:
	super._ready()
	add_to_group("bosses")

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if transitioning or state == State.DEAD:
		return
	super.take_damage(amount, knockback)
	boss_health_changed.emit(health, max_health)
	_check_phase_transition()

func _check_phase_transition() -> void:
	if current_phase > phase_thresholds.size():
		return
	var threshold := phase_thresholds[current_phase - 1]
	if float(health) / float(max_health) <= threshold:
		_start_phase_transition()

func _start_phase_transition() -> void:
	transitioning = true
	current_phase += 1
	state = State.STUNNED
	stunned_timer = 1.5
	GameManager.trigger_screen_shake(6.0, 0.5)
	phase_changed.emit(current_phase)
	await get_tree().create_timer(1.5).timeout
	transitioning = false
	state = State.APPROACH
	_on_phase_enter(current_phase)

func _on_phase_enter(phase: int) -> void:
	# Override in subclass to change behavior per phase
	pass

func _die() -> void:
	state = State.DEAD
	GameManager.add_score(score_value)
	remove_from_group("enemies")
	remove_from_group("bosses")
	died.emit(self)
	GameManager.trigger_screen_shake(8.0, 0.8)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(0.6)
	tween.tween_callback(queue_free)
