extends Control
# UC_04 - Sala autorów (hall of fame). Hover a figure to see the author's name.
# Nicknames are not filled in (the specification does not list any) - add them
# to the strings below if you want them to show up.

const AUTHORS := [
	{"name": "Franciszek Banaszkiewicz", "color": Color(0.9, 0.6, 0.2)},
	{"name": "Filip Kaczmarek", "color": Color(0.3, 0.7, 0.9)},
	{"name": "Jakub Markowski", "color": Color(0.5, 0.85, 0.4)},
	{"name": "Wiktoria Plewa", "color": Color(0.9, 0.4, 0.7)},
]

var name_label: Label

func _ready() -> void:
	size = Vector2(512, 256)

	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.1, 0.18)
	bg.size = size
	add_child(bg)

	var floor_rect := ColorRect.new()
	floor_rect.color = Color(0.25, 0.2, 0.3)
	floor_rect.position = Vector2(0, 140)
	floor_rect.size = Vector2(512, 116)
	add_child(floor_rect)

	var title := Label.new()
	title.text = "Sala autorów"
	title.position = Vector2(0, 14)
	title.size = Vector2(512, 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)

	for i in AUTHORS.size():
		_add_figure(i, AUTHORS[i])

	name_label = Label.new()
	name_label.position = Vector2(0, 196)
	name_label.size = Vector2(512, 26)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	add_child(name_label)

	var exit := Button.new()
	exit.text = "Wyjdź"
	exit.position = Vector2(420, 222)
	exit.size = Vector2(84, 28)
	exit.pressed.connect(_on_exit)
	add_child(exit)

func _add_figure(index: int, author: Dictionary) -> void:
	var x := 70.0 + index * 100.0
	var figure := ColorRect.new()  # body
	figure.color = author["color"]
	figure.position = Vector2(x, 90)
	figure.size = Vector2(32, 56)
	figure.mouse_filter = Control.MOUSE_FILTER_STOP
	figure.mouse_entered.connect(_on_figure_hover.bind(author["name"]))
	figure.mouse_exited.connect(_on_figure_leave)
	add_child(figure)

	var head := ColorRect.new()
	head.color = Color(0.95, 0.85, 0.7)
	head.position = Vector2(6, -22)
	head.size = Vector2(20, 20)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	figure.add_child(head)

func _on_figure_hover(author_name: String) -> void:
	name_label.text = author_name

func _on_figure_leave() -> void:
	name_label.text = ""

func _on_exit() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
