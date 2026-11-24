extends RoomBase
# UC_11 - Korona jabłoni. Postać X predicts the player's future, says she is
# being chased too and disappears. The player then jumps down from the tree.

var talked := false
var npc: Node2D

func _bg_color() -> Color:
	return Color(0.18, 0.45, 0.22)

func _player_start() -> Vector2:
	return Vector2(60, 140)

func _title() -> String:
	return "Korona jabłoni"

func _build() -> void:
	add_rect(Vector2(0, 118), Vector2(512, 44), Color(0.45, 0.3, 0.14), -5)
	add_door(Rect2(0, 110, 20, 60), JABLON, Vector2(394, 215))
	add_text("zeskok", Vector2(2, 94), 8)

	npc = Node2D.new()
	npc.position = Vector2(300, 100)
	add_child(npc)
	var body := ColorRect.new()
	body.size = Vector2(18, 30)
	body.color = Color(0.55, 0.2, 0.7)
	npc.add_child(body)
	var mark := Label.new()
	mark.text = "X"
	mark.position = Vector2(4, -18)
	mark.add_theme_font_size_override("font_size", 14)
	npc.add_child(mark)

	var zone := add_interact(Rect2(270, 90, 80, 60))
	zone.interacted.connect(_on_talk)

func _on_talk() -> void:
	if talked:
		return
	talked = true
	DialogueBox.show_text([
		"* Witaj, mały. Widzę, co cię czeka...",
		"* Kotka Indiana nie wybaczy ci tamtych jajek. Jej dzieci już po ciebie idą.",
		"* Mnie również ścigają. Obaj musimy uciekać!",
	])
	await DialogueBox.closed
	var fade := create_tween()
	fade.tween_property(npc, "modulate:a", 0.0, 0.6)
	await fade.finished
	npc.queue_free()
	DialogueBox.show_text(["* Postać zniknęła. Nie ma na co czekać – zeskakujesz z drzewa!"])
	await DialogueBox.closed
	RoomManager.change_room(JABLON, Vector2(394, 215))
