## Sprite sheet layout for characters.png
## Sheet: 384×192 — 8 columns × 3 rows, each frame 48×64 px
## KHN occupies columns 0-3; KLEK occupies columns 4-7
## Row 0 = IDLE  (3 frames per char, col 3/7 unused)
## Row 1 = WALK  (4 frames per char)
## Row 2 = ATTACK (2 frames per char, cols 2-3 / 6-7 unused)
extends RefCounted
class_name SpriteSheetConfig

const SHEET_PATH := "res://assets/sprites/characters.png"
const FRAME_W := 48
const FRAME_H := 64

# Returns Rect2 for a given column and row in the sheet
static func frame_rect(col: int, row: int) -> Rect2:
	return Rect2(col * FRAME_W, row * FRAME_H, FRAME_W, FRAME_H)

# KHN frame regions per animation
static func khn_idle_frames() -> Array[Rect2]:
	return [frame_rect(0, 0), frame_rect(1, 0), frame_rect(2, 0)]

static func khn_walk_frames() -> Array[Rect2]:
	return [frame_rect(0, 1), frame_rect(1, 1), frame_rect(2, 1), frame_rect(3, 1)]

static func khn_attack_frames() -> Array[Rect2]:
	return [frame_rect(0, 2), frame_rect(1, 2)]

# KLEK frame regions per animation
static func klek_idle_frames() -> Array[Rect2]:
	return [frame_rect(4, 0), frame_rect(5, 0), frame_rect(6, 0)]

static func klek_walk_frames() -> Array[Rect2]:
	return [frame_rect(4, 1), frame_rect(5, 1), frame_rect(6, 1), frame_rect(7, 1)]

static func klek_attack_frames() -> Array[Rect2]:
	return [frame_rect(4, 2), frame_rect(5, 2)]

# Build a SpriteFrames resource for one character.
# idle_rects / walk_rects / attack_rects: arrays of Rect2 into the sheet texture.
static func build_sprite_frames(
		texture: Texture2D,
		idle_rects: Array[Rect2],
		walk_rects: Array[Rect2],
		attack_rects: Array[Rect2]
) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")

	_add_anim(sf, "idle",   texture, idle_rects,   8.0,  true)
	_add_anim(sf, "walk",   texture, walk_rects,   10.0, true)
	_add_anim(sf, "attack", texture, attack_rects, 12.0, false)
	_add_anim(sf, "hurt",   texture, [idle_rects[0]], 6.0, false)
	_add_anim(sf, "dead",   texture, [idle_rects[0]], 4.0, false)
	_add_anim(sf, "special",texture, attack_rects,  14.0, false)

	return sf

static func _add_anim(sf: SpriteFrames, anim: String, tex: Texture2D,
		rects: Array[Rect2], fps: float, loop: bool) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for r in rects:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = r
		sf.add_frame(anim, at)
