extends CanvasLayer

var is_open := false
var lines: Array = []
var line_index := 0
var tween: Tween

var panel: Panel
var label: Label

func _ready() -> void:
	layer = 10

	panel = Panel.new()
	panel.position = Vector2(32, 330)
	panel.size = Vector2(576, 120)
	var style := StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.border_color = Color.WHITE
	style.set_border_width_all(4)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	label = Label.new()
	label.position = Vector2(16, 12)
	label.size = Vector2(544, 96)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24)
	panel.add_child(label)

	panel.visible = false

func show_text(new_lines: Array) -> void:
	lines = new_lines
	line_index = 0
	is_open = true
	panel.visible = true
	_show_line()

func _show_line() -> void:
	label.text = lines[line_index]
	label.visible_ratio = 0.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, lines[line_index].length() * 0.04)

func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if label.visible_ratio < 1.0:
			tween.kill()
			label.visible_ratio = 1.0
		else:
			line_index += 1
			if line_index >= lines.size():
				is_open = false
				panel.visible = false
			else:
				_show_line()
