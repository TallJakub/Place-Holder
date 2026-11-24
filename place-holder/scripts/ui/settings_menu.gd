extends Control
# UC_03 - Menu ustawień: music volume, sound-effects volume, confirm (back to UC_01).

func _ready() -> void:
	size = Vector2(512, 256)

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.13)
	bg.size = size
	add_child(bg)

	var title := Label.new()
	title.text = "Ustawienia"
	title.position = Vector2(0, 20)
	title.size = Vector2(512, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	add_child(title)

	var music_slider := _add_slider("Głośność muzyki", 80, Settings.music_volume)
	music_slider.value_changed.connect(_on_music_changed)
	var sfx_slider := _add_slider("Głośność efektów dźwiękowych", 130, Settings.sfx_volume)
	sfx_slider.value_changed.connect(_on_sfx_changed)

	var confirm := Button.new()
	confirm.text = "Potwierdź"
	confirm.position = Vector2(186, 192)
	confirm.custom_minimum_size = Vector2(140, 30)
	confirm.add_theme_font_size_override("font_size", 16)
	confirm.pressed.connect(_on_confirm)
	add_child(confirm)
	music_slider.grab_focus()

func _add_slider(text: String, y: float, value: float) -> HSlider:
	var label := Label.new()
	label.text = text
	label.position = Vector2(96, y)
	label.size = Vector2(320, 20)
	label.add_theme_font_size_override("font_size", 14)
	add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.position = Vector2(96, y + 22)
	slider.size = Vector2(320, 18)
	add_child(slider)
	return slider

func _on_music_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.apply()

func _on_sfx_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.apply()

func _on_confirm() -> void:
	Settings.save_settings()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
