extends Node

signal score_changed(new_score: int)
signal stage_changed(stage_num: int)

# --- Game State ---
var current_stage: int = 1
var num_players: int = 1
var score: int = 0
var high_score: int = 0

# Character selection (0=KHN, 1=KLEK; in 2P mode both are used)
var selected_character: int = 0

# Unlockables
var tlmep_mode_unlocked: bool = false
var hotdog_vinyl_unlocked: bool = false
var sardine_vinyl_unlocked: bool = false

# Stage 4 perfect-run tracking (unlocks TLMEP mode)
var stage4_took_damage: bool = false
var stage4_missed_sync: bool = false

# Screen shake (polled by Game scene camera)
var shake_remaining: float = 0.0
var shake_intensity: float = 0.0

# --- Music ---
var _music_player: AudioStreamPlayer = null
var _current_music_path: String = ""
const MUSIC_GRAVITY_BOUND := "res://assets/audio/gravity_bound.mp3"
const MUSIC_FINAL_PANIC   := "res://assets/audio/final_level_panic.mp3"

# Stage scene paths
const STAGE_PATHS: Array[String] = [
	"",  # index 0 unused
	"res://scripts/stages/Stage1.gd",
	"res://scripts/stages/Stage2.gd",
	"res://scripts/stages/Stage3.gd",
	"res://scripts/stages/Stage4.gd",
	"res://scripts/stages/Stage5.gd",
	"res://scripts/stages/Stage6.gd",
]

const STAGE_NAMES: Array[String] = [
	"",
	"SHERPA",
	"MATA ZYKLEK",
	"SARNIEZZ",
	"UTZP",
	"YOR ZARAD",
	"ANGOR",
]

const STAGE_LOCATIONS: Array[String] = [
	"",
	"The Chicoutimi Tavern",
	"The Highway out of Saguenay",
	"The Montreal Jazz Festival Grounds",
	"The TLMEP Television Studio, Montréal",
	"The Pyramide des Ha! Ha!, Saguenay",
	"The SPEC-13 Pyramid Tower, Top Floor",
]

func _ready() -> void:
	_setup_input_actions()
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	_music_player.volume_db = -6.0
	add_child(_music_player)

func _process(delta: float) -> void:
	if shake_remaining > 0.0:
		shake_remaining -= delta
		if shake_remaining <= 0.0:
			shake_remaining = 0.0
			shake_intensity = 0.0

func _setup_input_actions() -> void:
	var bindings: Dictionary = {
		"p1_left":    [KEY_A],
		"p1_right":   [KEY_D],
		"p1_up":      [KEY_W],
		"p1_down":    [KEY_S],
		"p1_attack":  [KEY_J],
		"p1_kick":    [KEY_K],
		"p1_jump":    [KEY_L],
		"p1_special": [KEY_I],
		"p2_left":    [KEY_LEFT],
		"p2_right":   [KEY_RIGHT],
		"p2_up":      [KEY_UP],
		"p2_down":    [KEY_DOWN],
		"p2_attack":  [KEY_KP_4],
		"p2_kick":    [KEY_KP_5],
		"p2_jump":    [KEY_KP_6],
		"p2_special": [KEY_KP_7],
		"ui_start":   [KEY_ENTER, KEY_SPACE],
		"ui_back":    [KEY_ESCAPE],
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.5)
			for k in bindings[action]:
				var ev := InputEventKey.new()
				ev.keycode = k
				InputMap.action_add_event(action, ev)

func start_game(players: int) -> void:
	num_players = players
	current_stage = 1
	score = 0
	stage4_took_damage = false
	stage4_missed_sync = false
	if players == 1:
		get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")
	else:
		selected_character = 0  # 2P: KHN=P1, KLEK=P2 (both active)
		get_tree().change_scene_to_file("res://scenes/Game.tscn")

func add_score(points: int) -> void:
	score += points
	high_score = max(high_score, score)
	score_changed.emit(score)

func trigger_screen_shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_remaining = duration

func get_shake_offset() -> Vector2:
	if shake_remaining <= 0.0:
		return Vector2.ZERO
	return Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)

func advance_stage() -> void:
	if current_stage == 4:
		if not stage4_took_damage and not stage4_missed_sync:
			tlmep_mode_unlocked = true
	current_stage += 1
	if current_stage > 6:
		get_tree().change_scene_to_file("res://scenes/Ending.tscn")
	else:
		stage_changed.emit(current_stage)

func play_music(path: String, loop: bool = true) -> void:
	if path == _current_music_path and _music_player.playing:
		return
	if not ResourceLoader.exists(path):
		return
	var stream := load(path)
	if stream is AudioStreamMP3:
		stream.loop = loop
	_music_player.stream = stream
	_music_player.play()
	_current_music_path = path

func stop_music() -> void:
	_music_player.stop()
	_current_music_path = ""

func play_music_for_stage(stage_num: int) -> void:
	if stage_num >= 6:
		play_music(MUSIC_FINAL_PANIC)
	else:
		play_music(MUSIC_GRAVITY_BOUND)

func game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
