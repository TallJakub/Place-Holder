extends RoomBase
# UC_06 - Dwór. Three paths on the right edge: 1 = jabłoń, 2 = woda, 3 = polana.
# The coop cannot be re-entered.

const PATHS := [
	{"label": "1", "y": 44.0, "target": JABLON},
	{"label": "2", "y": 128.0, "target": WODA},
	{"label": "3", "y": 212.0, "target": POLANA},
]

func _bg_color() -> Color:
	return Color(0.38, 0.7, 0.32)

func _player_start() -> Vector2:
	return Vector2(80, 175)

func _title() -> String:
	return "Dwór"

func _build() -> void:
	# the coop (not enterable)
	add_solid(Vector2(16, 16), Vector2(110, 80), Color(0.55, 0.35, 0.2))
	add_text("Kurnik", Vector2(44, 44), 10)
	var coop := add_interact(Rect2(16, 96, 110, 40))
	coop.interacted.connect(_on_coop_interacted)

	for path in PATHS:
		var y: float = path["y"]
		add_rect(Vector2(300, y - 14), Vector2(212, 28), Color(0.6, 0.5, 0.3), -5)
		add_text(path["label"], Vector2(440, y - 16), 22, Color(1, 1, 0.5))
		add_door(Rect2(488, y - 28, 24, 56), path["target"], Vector2(56, 128))

func _on_coop_interacted() -> void:
	DialogueBox.show_text(["* Nie ma po co wracać do kurnika."])
