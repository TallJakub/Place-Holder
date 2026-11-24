class_name WaterRoom
extends RoomBase
# Shared logic of the water rooms (UC_09 / UC_12): the oxygen bar, the pulsing
# "R" prompt and gills. Until the player presses R oxygen drains; at 0 oxygen
# the player slowly loses HP. After pressing R (GameState.gills) he can breathe
# underwater in every water room.

const OXYGEN_DRAIN := 5.0       # per second -> ~20 s of air
const SUFFOCATE_DAMAGE := 5     # HP per second at 0 oxygen
const PROMPT_DELAY := 1.5

var oxygen := 100.0
var suffocate_timer := 0.0
var prompt_visible := false

var ui_layer: CanvasLayer
var bar_fill: ColorRect
var bar_label: Label
var r_prompt: Label

func _ready() -> void:
	super()
	player.set("speed", 100.0)  # swimming is slower
	_build_oxygen_ui()
	if not GameState.gills:
		_show_r_prompt()

func _build_oxygen_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 5
	add_child(ui_layer)

	var border := ColorRect.new()
	border.color = Color.WHITE
	border.position = Vector2(156, 238)
	border.size = Vector2(200, 12)
	ui_layer.add_child(border)

	var inner := ColorRect.new()
	inner.color = Color(0.05, 0.05, 0.1)
	inner.position = Vector2(2, 2)
	inner.size = Vector2(196, 8)
	border.add_child(inner)

	bar_fill = ColorRect.new()
	bar_fill.color = Color(0.3, 0.8, 1.0)
	bar_fill.position = Vector2(2, 2)
	bar_fill.size = Vector2(196, 8)
	border.add_child(bar_fill)

	bar_label = Label.new()
	bar_label.position = Vector2(156, 222)
	bar_label.size = Vector2(200, 14)
	bar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bar_label.add_theme_font_size_override("font_size", 9)
	bar_label.add_theme_color_override("font_outline_color", Color.BLACK)
	bar_label.add_theme_constant_override("outline_size", 3)
	ui_layer.add_child(bar_label)

	r_prompt = Label.new()
	r_prompt.text = "R"
	r_prompt.position = Vector2(0, 90)
	r_prompt.size = Vector2(512, 60)
	r_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	r_prompt.add_theme_font_size_override("font_size", 48)
	r_prompt.add_theme_color_override("font_color", Color(1, 1, 0.4))
	r_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	r_prompt.add_theme_constant_override("outline_size", 6)
	r_prompt.visible = false
	ui_layer.add_child(r_prompt)

func _show_r_prompt() -> void:
	await get_tree().create_timer(PROMPT_DELAY).timeout
	if GameState.gills:
		return
	prompt_visible = true
	r_prompt.visible = true
	var t := r_prompt.create_tween().set_loops()
	t.tween_property(r_prompt, "modulate:a", 0.2, 0.5)
	t.tween_property(r_prompt, "modulate:a", 1.0, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if prompt_visible and not GameState.gills and not GameState.dead \
			and event.is_action_pressed("breathe"):
		get_viewport().set_input_as_handled()
		GameState.gills = true
		prompt_visible = false
		r_prompt.visible = false
		DialogueBox.show_text([
			"* Na szyi otwierają ci się skrzela!",
			"* Możesz oddychać pod wodą.",
		])

func _process(delta: float) -> void:
	if GameState.dead:
		return
	if GameState.gills:
		oxygen = 100.0
	else:
		oxygen = maxf(oxygen - OXYGEN_DRAIN * delta, 0.0)
		if oxygen <= 0.0:
			suffocate_timer += delta
			if suffocate_timer >= 1.0:
				suffocate_timer = 0.0
				GameState.damage(SUFFOCATE_DAMAGE)
	_update_oxygen_ui()

func _update_oxygen_ui() -> void:
	if GameState.gills:
		bar_fill.color = Color(0.2, 0.9, 0.7)
		bar_fill.size.x = 196.0
		bar_label.text = "SKRZELA"
	else:
		bar_fill.color = Color(0.3, 0.8, 1.0)
		bar_fill.size.x = 196.0 * oxygen / 100.0
		bar_label.text = "TLEN"
