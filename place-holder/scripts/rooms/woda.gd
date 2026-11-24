extends WaterRoom
# UC_09 - Poziom wodny. Oxygen / gills logic lives in WaterRoom.
# The trench at the bottom leads to the lake floor (UC_12).

func _bg_color() -> Color:
	return Color(0.12, 0.33, 0.68)

func _player_start() -> Vector2:
	return Vector2(56, 128)

func _title() -> String:
	return "Jezioro"

func _build() -> void:
	add_door(Rect2(0, 100, 20, 56), DWOR, Vector2(440, 128))

	# a few lighter patches to give the water some texture
	for pos in [Vector2(90, 40), Vector2(300, 60), Vector2(420, 180), Vector2(150, 190)]:
		add_rect(pos, Vector2(60, 14), Color(0.2, 0.42, 0.78), -5)

	add_rect(Vector2(200, 226), Vector2(112, 30), Color(0.04, 0.08, 0.25), -5)
	add_text("Głębiny ▼", Vector2(222, 208), 9)
	add_door(Rect2(200, 238, 112, 18), DNO, Vector2(56, 128), Color(0, 0, 0, 0))
