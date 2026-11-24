extends CanvasLayer

var max_hp: int = 100
var hp: int = 100
var dead := false
var can_respawn := false

# Where you come back after dying: the first story room (UC_05, kurnik).
var respawn_room := "res://scenes/rooms/kurnik.tscn"
var respawn_position := Vector2(90, 190)

# Story progress (reset by reset() when a new game starts)
var tongue_learned := false   # UC_08: first apple teaches the tongue
var gills := false            # UC_09: R pressed, can breathe underwater
var apples_collected := 0

# UC_12: "sanity" bar, shown after the skeleton on the lake floor was found.
# Below SANITY_LOW percent the player slowly loses HP.
const SANITY_LOW := 20.0
const SANITY_DRAIN := 0.5      # percent per second
var sanity := 100.0
var sanity_enabled := false
var sanity_hurt_timer := 0.0
var sanity_root: Control
var sanity_fill: ColorRect

const BAR_W := 100.0
const BAR_H := 14.0

var bar_fill: ColorRect
var hp_label: Label
var overlay: Control
var prompt: Label
var prompt_tween: Tween

func _ready() -> void:
	layer = 20
	hp = max_hp
	var vp := get_viewport().get_visible_rect().size
	_build_bar(vp)
	_build_game_over(vp)
	_build_sanity_bar(vp)

func _style_label(label: Label, size: int) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)

func _build_bar(vp: Vector2) -> void:
	var x := vp.x - BAR_W - 12.0
	var y := 10.0

	var tag := Label.new()
	tag.text = "HP"
	tag.position = Vector2(x - 24, y - 2)
	_style_label(tag, 12)
	add_child(tag)

	var border := ColorRect.new()
	border.color = Color.WHITE
	border.position = Vector2(x, y)
	border.size = Vector2(BAR_W, BAR_H)
	add_child(border)

	var inner := ColorRect.new()
	inner.color = Color(0.1, 0.1, 0.1)
	inner.position = Vector2(2, 2)
	inner.size = Vector2(BAR_W - 4, BAR_H - 4)
	border.add_child(inner)

	bar_fill = ColorRect.new()
	bar_fill.position = Vector2(2, 2)
	bar_fill.size = Vector2(BAR_W - 4, BAR_H - 4)
	border.add_child(bar_fill)

	hp_label = Label.new()
	hp_label.position = Vector2(0, -1)
	hp_label.size = Vector2(BAR_W, BAR_H)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_label(hp_label, 9)
	border.add_child(hp_label)

	_update_bar(false)

func _build_game_over(vp: Vector2) -> void:
	overlay = Control.new()
	overlay.size = vp
	overlay.visible = false
	add_child(overlay)

	var dim := ColorRect.new()
	dim.color = Color(0.3, 0, 0, 0.85)
	dim.size = vp
	overlay.add_child(dim)

	var title := Label.new()
	title.text = "GAME OVER"
	title.size = Vector2(vp.x, 50)
	title.position = Vector2(0, vp.y * 0.30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.9, 0.1, 0.1))
	overlay.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "You were defeated..."
	subtitle.size = Vector2(vp.x, 24)
	subtitle.position = Vector2(0, vp.y * 0.48)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_child(subtitle)
	prompt = Label.new()
	prompt.text = "Press Space to respawn"
	prompt.size = Vector2(vp.x, 24)
	prompt.position = Vector2(0, vp.y * 0.62)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 16)
	overlay.add_child(prompt)

func _update_bar(animate: bool = true) -> void:
	var ratio := float(hp) / float(max_hp)
	var target := (BAR_W - 4.0) * ratio
	bar_fill.color = Color.from_hsv(0.33 * ratio, 0.8, 0.9)
	hp_label.text = str(hp) + "/" + str(max_hp)
	if animate:
		create_tween().tween_property(bar_fill, "size:x", target, 0.15)
	else:
		bar_fill.size.x = target

func damage(amount: int) -> void:
	if dead:
		return
	hp = maxi(hp - amount, 0)
	_update_bar()
	if hp <= 0:
		_die()

func _die() -> void:
	dead = true
	can_respawn = false
	overlay.modulate.a = 0.0
	overlay.visible = true
	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 1.0, 0.6)
	t.tween_callback(_enable_respawn)

func _enable_respawn() -> void:
	can_respawn = true
	prompt_tween = create_tween().set_loops()
	prompt_tween.tween_property(prompt, "modulate:a", 0.2, 0.6)
	prompt_tween.tween_property(prompt, "modulate:a", 1.0, 0.6)

# While dead, swallow all input except the respawn key.
func _input(event: InputEvent) -> void:
	if not dead:
		return
	get_viewport().set_input_as_handled()
	if can_respawn and event.is_action_pressed("interact"):
		_respawn()

func _respawn() -> void:
	can_respawn = false
	if prompt_tween:
		prompt_tween.kill()
	hp = max_hp
	sanity = 100.0
	_update_sanity_bar()
	_update_bar()
	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 0.25)
	RoomManager.change_room(respawn_room, respawn_position)
	await t.finished
	overlay.visible = false
	dead = false

func heal(amount: int) -> void:
	if dead:
		return
	hp = mini(hp + amount, max_hp)
	_update_bar()

# New game from the menu: forget all progress.
func reset() -> void:
	if prompt_tween:
		prompt_tween.kill()
	dead = false
	can_respawn = false
	overlay.visible = false
	hp = max_hp
	tongue_learned = false
	gills = false
	apples_collected = 0
	sanity = 100.0
	sanity_enabled = false
	sanity_root.visible = false
	_update_bar(false)

func enable_sanity() -> void:
	sanity_enabled = true
	sanity_root.visible = true
	_update_sanity_bar()

func _build_sanity_bar(vp: Vector2) -> void:
	sanity_root = Control.new()
	sanity_root.visible = false
	add_child(sanity_root)

	var x := vp.x - BAR_W - 12.0
	var y := vp.y - BAR_H - 10.0

	var tag := Label.new()
	tag.text = "SANITY"
	tag.position = Vector2(x - 56, y - 2)
	_style_label(tag, 11)
	sanity_root.add_child(tag)

	var border := ColorRect.new()
	border.color = Color.WHITE
	border.position = Vector2(x, y)
	border.size = Vector2(BAR_W, BAR_H)
	sanity_root.add_child(border)

	var inner := ColorRect.new()
	inner.color = Color(0.1, 0.1, 0.1)
	inner.position = Vector2(2, 2)
	inner.size = Vector2(BAR_W - 4, BAR_H - 4)
	border.add_child(inner)

	sanity_fill = ColorRect.new()
	sanity_fill.position = Vector2(2, 2)
	sanity_fill.size = Vector2(BAR_W - 4, BAR_H - 4)
	border.add_child(sanity_fill)

func _update_sanity_bar() -> void:
	if sanity_fill == null:
		return
	sanity_fill.size.x = (BAR_W - 4.0) * clampf(sanity / 100.0, 0.0, 1.0)
	sanity_fill.color = Color(0.9, 0.2, 0.2) if sanity < SANITY_LOW else Color(0.6, 0.4, 0.95)

func _process(delta: float) -> void:
	if not sanity_enabled or dead:
		return
	sanity = maxf(sanity - SANITY_DRAIN * delta, 0.0)
	_update_sanity_bar()
	if sanity < SANITY_LOW:
		sanity_hurt_timer += delta
		if sanity_hurt_timer >= 2.0:
			sanity_hurt_timer = 0.0
			damage(1)
