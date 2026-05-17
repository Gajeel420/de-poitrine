## Game.tscn root — dynamically loads and transitions between stages.
extends Node2D

var current_stage_node: Node2D = null

const STAGE_SCRIPTS: Array[String] = [
	"",
	"res://scripts/stages/Stage1.gd",
	"res://scripts/stages/Stage2.gd",
	"res://scripts/stages/Stage3.gd",
	"res://scripts/stages/Stage4.gd",
	"res://scripts/stages/Stage5.gd",
	"res://scripts/stages/Stage6.gd",
]

func _ready() -> void:
	GameManager.stage_changed.connect(_on_stage_changed)
	_load_stage(GameManager.current_stage)

func _load_stage(stage_num: int) -> void:
	if current_stage_node:
		current_stage_node.queue_free()
		current_stage_node = null

	if stage_num < 1 or stage_num >= STAGE_SCRIPTS.size():
		return

	var stage_script := load(STAGE_SCRIPTS[stage_num])
	var stage := Node2D.new()
	stage.set_script(stage_script)
	add_child(stage)
	current_stage_node = stage
	GameManager.play_music_for_stage(stage_num)

func _on_stage_changed(stage_num: int) -> void:
	# Brief black fade between stages
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fade)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	await tween.finished
	_load_stage(stage_num)
	tween = create_tween()
	tween.tween_property(fade, "color:a", 0.0, 0.5)
	await tween.finished
	fade.queue_free()
