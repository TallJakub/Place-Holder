extends Control
# UC_01 - Menu: Graj / Ustawienia / Autorzy / Wyjdź

func _ready() -> void:
	size = Vector2(512, 256)

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.13)
	bg.size = size
	add_child(bg)

	var title := Label.new()
	title.text = "Place Holder"
	title.position = Vector2(0, 22)
	title.size = Vector2(512, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	add_child(title)

	var box := VBoxContainer.new()
	box.position = Vector2(186, 88)
	box.custom_minimum_size = Vector2(140, 0)
	box.add_theme_constant_override("separation", 6)
	add_child(box)

	var play := _add_button(box, "Graj", _on_play)
	_add_button(box, "Ustawienia", _on_settings)
	_add_button(box, "Autorzy", _on_authors)
	_add_button(box, "Wyjdź", _on_quit)
	play.grab_focus()

func _add_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(140, 30)
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _on_play() -> void:
	GameState.reset()
	RoomManager.has_spawn = false
	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_authors() -> void:
	get_tree().change_scene_to_file("res://scenes/authors.tscn")

func _on_quit() -> void:
	get_tree().quit()
