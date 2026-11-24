extends WaterRoom
# UC_12 - Dno jeziora. The player explores the lake floor and finds a skeleton
# of an animal like himself: he loses 20 HP, is thrown back to the dwór and from
# now on the "sanity" bar is shown (below 20% he starts losing HP).

const SKELETON_POS := Vector2(440, 128)
const SKELETON_DAMAGE := 20

var found := false

func _bg_color() -> Color:
	return Color(0.04, 0.09, 0.24)

func _player_start() -> Vector2:
	return Vector2(56, 128)

func _title() -> String:
	return "Dno jeziora"

func _build() -> void:
	add_door(Rect2(0, 100, 20, 56), WODA, Vector2(256, 200))

	# rocks to explore around
	add_solid(Vector2(150, 40), Vector2(40, 30), Color(0.15, 0.2, 0.35))
	add_solid(Vector2(240, 160), Vector2(60, 36), Color(0.15, 0.2, 0.35))
	add_solid(Vector2(330, 60), Vector2(36, 44), Color(0.15, 0.2, 0.35))

	# skeleton
	add_rect(SKELETON_POS + Vector2(-14, -4), Vector2(28, 8), Color(0.9, 0.9, 0.85), 1)
	add_rect(SKELETON_POS + Vector2(-20, -10), Vector2(10, 12), Color(0.95, 0.95, 0.9), 1)
	add_rect(SKELETON_POS + Vector2(-6, 2), Vector2(4, 12), Color(0.9, 0.9, 0.85), 1)
	add_rect(SKELETON_POS + Vector2(6, 2), Vector2(4, 12), Color(0.9, 0.9, 0.85), 1)

	var zone := add_area(Rect2(SKELETON_POS - Vector2(26, 24), Vector2(52, 48)))
	zone.body_entered.connect(_on_skeleton_touched)

func _on_skeleton_touched(body: Node2D) -> void:
	if found or not body.is_in_group("player"):
		return
	found = true
	DialogueBox.show_text([
		"* Na dnie leży szkielet zwierzęcia. Wygląda dokładnie jak ty...",
		"* W głowie ci się kręci. Tracisz przytomność.",
	])
	await DialogueBox.closed
	GameState.damage(SKELETON_DAMAGE)
	GameState.enable_sanity()
	if not GameState.dead:
		RoomManager.change_room(DWOR, Vector2(440, 128))
