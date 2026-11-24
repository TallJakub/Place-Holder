extends Control
# UC_02 - Wejście do gry (cutscenka). Space / Enter = next, Esc = skip.
# Afterwards the game continues in the kurnik (UC_05).

const SLIDES := [
	"Dawid Nadsiadło był jeszcze jajkiem. Rodzice go nie chcieli.",
	"Wyrzucili go do innych jajek w kurniku.",
	"Tuż przed wykluciem Dawid wywalił inne jajka z gniazda.",
	"Kaczka architekt wszystko widziała. Poszła do Indiany – kotki – i opowiedziała jej całą historię.",
	"Indiana planuje zemstę. Wysyła swoje dzieci do walki z Dawidem.",
]

var index := 0
var label: Label
var tween: Tween
var finished := false

func _ready() -> void:
	size = Vector2(512, 256)

	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.size = size
	add_child(bg)

	label = Label.new()
	label.position = Vector2(40, 80)
	label.size = Vector2(432, 100)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)

	var hint := Label.new()
	hint.text = "[Spacja] dalej    [Esc] pomiń"
	hint.position = Vector2(0, 232)
	hint.size = Vector2(512, 20)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 10)
	hint.modulate = Color(1, 1, 1, 0.5)
	add_child(hint)

	_show_slide()

func _show_slide() -> void:
	label.text = SLIDES[index]
	label.visible_ratio = 0.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, SLIDES[index].length() * 0.04)

func _unhandled_input(event: InputEvent) -> void:
	if finished:
		return
	if event.is_action_pressed("ui_cancel"):
		_finish()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if label.visible_ratio < 1.0:
			tween.kill()
			label.visible_ratio = 1.0
		else:
			index += 1
			if index >= SLIDES.size():
				_finish()
			else:
				_show_slide()

func _finish() -> void:
	finished = true
	RoomManager.change_room(RoomBase.KURNIK, Vector2(90, 190))
