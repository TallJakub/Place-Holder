extends RoomBase
# UC_10 - Polana z roślinami. Every plant gives a different effect (see Pickup
# and the effect system in player.gd). The plants are not labelled on purpose -
# the player has to find out what each of them does.
#
#   blue berries  -> speed      red mushroom -> hallucinations
#   green aloe    -> cures hallucinations + regeneration
#   pink flowers  -> strength   dark nettle  -> poison

func _bg_color() -> Color:
	return Color(0.45, 0.76, 0.35)

func _player_start() -> Vector2:
	return Vector2(56, 128)

func _title() -> String:
	return "Polana"

func _build() -> void:
	add_door(Rect2(0, 100, 20, 56), DWOR, Vector2(440, 212))

	# grass tufts
	for pos in [Vector2(80, 40), Vector2(160, 200), Vector2(260, 110), Vector2(400, 120), Vector2(340, 230)]:
		add_rect(pos, Vector2(24, 10), Color(0.35, 0.65, 0.28), -5)

	add_child(Pickup.create("blueberry", Vector2(130, 60), Color(0.2, 0.2, 0.85)))
	add_child(Pickup.create("fly_agaric", Vector2(210, 190), Color(0.9, 0.1, 0.1)))
	add_child(Pickup.create("aloe", Vector2(300, 70), Color(0.45, 0.95, 0.55)))
	add_child(Pickup.create("flower", Vector2(390, 180), Color(1.0, 0.6, 0.8)))
	add_child(Pickup.create("nettle", Vector2(450, 70), Color(0.08, 0.45, 0.12)))
