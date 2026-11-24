extends RoomBase
# UC_08 - Jabłoń. Apples lie on the ground and hang on branches. Branch apples
# can only be reached with the tongue (T). The trunk leads up to the crown (UC_11).

func _bg_color() -> Color:
	return Color(0.4, 0.72, 0.34)

func _player_start() -> Vector2:
	return Vector2(56, 128)

func _title() -> String:
	return "Jabłoń"

func _build() -> void:
	add_door(Rect2(0, 100, 20, 56), DWOR, Vector2(440, 44))

	# river with a bridge
	add_solid(Vector2(100, 0), Vector2(32, 100), Color(0.2, 0.45, 0.85))
	add_solid(Vector2(100, 156), Vector2(32, 100), Color(0.2, 0.45, 0.85))
	add_rect(Vector2(100, 100), Vector2(32, 56), Color(0.5, 0.35, 0.2), -5)
	add_text("most", Vector2(103, 84), 8)

	# tree
	add_solid(Vector2(330, 16), Vector2(130, 76), Color(0.12, 0.45, 0.15))   # crown
	add_solid(Vector2(380, 92), Vector2(28, 64), Color(0.45, 0.28, 0.12))    # trunk
	add_text("▲ Wejście na drzewo (Spacja)", Vector2(318, 186), 8, Color(1, 1, 0.6))

	var climb := add_interact(Rect2(366, 156, 56, 30))
	climb.interacted.connect(_on_climb)

	# apples on the branches (tongue only)
	for pos in [Vector2(350, 40), Vector2(420, 60), Vector2(445, 32)]:
		add_child(Pickup.create("apple", pos, Color(0.9, 0.1, 0.1), true, 10.0))
	# apples on the ground
	for pos in [Vector2(300, 200), Vector2(250, 150), Vector2(210, 70)]:
		add_child(Pickup.create("apple", pos, Color(0.9, 0.15, 0.15), false, 10.0))

func _on_climb() -> void:
	DialogueBox.show_text(["* Wspinasz się na jabłoń..."])
	await DialogueBox.closed
	RoomManager.change_room(KORONA, Vector2(60, 140))
