extends RoomBase
# UC_05 - Kurnik. Starting location. Kaczka architekt quacks; when the player
# comes close she pecks him (-10 HP) and chases him out to the dwór.
# Leaving through the exit on the left costs nothing.

const DUCK_POS := Vector2(380, 120)
const PECK_DAMAGE := 10

var expelled := false
var quack_label: Label

func _bg_color() -> Color:
	return Color(0.72, 0.58, 0.35)

func _player_start() -> Vector2:
	return Vector2(90, 190)

func _title() -> String:
	return "Kurnik"

func _build() -> void:
	add_rect(Vector2(40, 150), Vector2(120, 80), Color(0.85, 0.75, 0.4), -5)
	add_rect(Vector2(300, 30), Vector2(160, 60), Color(0.85, 0.75, 0.4), -5)

	add_door(Rect2(0, 100, 20, 60), DWOR, Vector2(80, 175))
	add_text("WYJŚCIE", Vector2(4, 84), 8)

	# Kaczka architekt
	add_solid(DUCK_POS + Vector2(-16, -10), Vector2(32, 26), Color(0.95, 0.85, 0.2))
	add_rect(DUCK_POS + Vector2(-26, -4), Vector2(10, 6), Color(0.95, 0.5, 0.1), 1)  # beak
	add_text("Kaczka architekt", DUCK_POS + Vector2(-44, -34), 9)
	quack_label = add_text("KWA!", DUCK_POS + Vector2(-14, -50), 12, Color(1, 0.9, 0.3))
	quack_label.visible = false

	var quack := create_tween().set_loops()
	quack.tween_interval(2.0)
	quack.tween_callback(quack_label.set_visible.bind(true))
	quack.tween_interval(0.6)
	quack.tween_callback(quack_label.set_visible.bind(false))

	var zone := add_area(Rect2(DUCK_POS - Vector2(70, 70), Vector2(140, 140)))
	zone.body_entered.connect(_on_duck_zone_entered)

func _on_duck_zone_entered(body: Node2D) -> void:
	if expelled or not body.is_in_group("player"):
		return
	expelled = true
	DialogueBox.show_text([
		"* KWAAAA!",
		"* Kaczka architekt dziobie cię i wygania z kurnika!",
	])
	await DialogueBox.closed
	GameState.damage(PECK_DAMAGE)
	if not GameState.dead:
		RoomManager.change_room(DWOR, Vector2(80, 175))
