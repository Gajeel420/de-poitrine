## HUD — CanvasLayer drawn procedurally
## Shows health bars, special meters, boss HP, score, lives, stage name
extends CanvasLayer

var stage_number: int = 1
var num_players: int = 1

# Player state
var p1_hp: float = 1.0
var p1_hp_max: float = 1.0
var p2_hp: float = 1.0
var p2_hp_max: float = 1.0
var p1_special: float = 0.0
var p1_special_max: float = 100.0
var p2_special: float = 0.0
var p2_special_max: float = 100.0

# Boss HP bar
var boss_hp: float = 1.0
var boss_hp_max: float = 1.0
var boss_visible: bool = false
var boss_node: Node = null
var boss_name_text: String = ""

# Score display
var displayed_score: int = 0

# Stage name flash
var stage_name_timer: float = 3.0

var draw_node: Node2D

func _ready() -> void:
	# Create a Node2D child to do the actual drawing (CanvasLayer can't _draw)
	draw_node = Node2D.new()
	draw_node.set_script(load("res://scripts/HUDDrawer.gd"))
	add_child(draw_node)
	# Set hud reference after add_child so script is initialized
	draw_node.hud = self
	GameManager.score_changed.connect(_on_score_changed)

func _process(delta: float) -> void:
	stage_name_timer -= delta
	if boss_node and is_instance_valid(boss_node):
		boss_hp = float(boss_node.health)
		boss_hp_max = float(boss_node.max_health)
	displayed_score = GameManager.score
	draw_node.queue_redraw()

func update_player_hp(player_id: int, hp: int, max_hp: int) -> void:
	if player_id == 1:
		p1_hp = float(hp); p1_hp_max = float(max_hp)
	else:
		p2_hp = float(hp); p2_hp_max = float(max_hp)

func update_player_special(player_id: int, val: float, max_val: float) -> void:
	if player_id == 1:
		p1_special = val; p1_special_max = max_val
	else:
		p2_special = val; p2_special_max = max_val

func show_boss_hp(boss: Node) -> void:
	boss_node = boss
	boss_visible = true
	boss_hp_max = float(boss.max_health)
	boss_hp = boss_hp_max
	match stage_number:
		1: boss_name_text = "THE VENUE OWNER"
		2: boss_name_text = "THE CURATOR BOT"
		3: boss_name_text = "IMPERSONATOR PRIME"
		4: boss_name_text = "THE BROADCAST DIRECTOR"
		5: boss_name_text = "THE MONUMENT"
		6: boss_name_text = "FABIO SPEK-TROIS"

func _on_score_changed(new_score: int) -> void:
	displayed_score = new_score
