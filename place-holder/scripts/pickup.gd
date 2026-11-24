class_name Pickup
extends Area2D
# Collectable item: apples (UC_08) and plants on the clearing (UC_10).
# Collected by walking over it, or by pulling it with the tongue (T).
# Items with needs_tongue = true cannot be walked over (apples on branches).

@export var kind := ""
@export var needs_tongue := false

var collected := false

static func create(pickup_kind: String, pos: Vector2, color: Color, tongue_only: bool = false, size: float = 12.0) -> Pickup:
	var pickup := Pickup.new()
	pickup.kind = pickup_kind
	pickup.needs_tongue = tongue_only
	pickup.position = pos

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = size * 0.8
	shape.shape = circle
	pickup.add_child(shape)

	var visual := ColorRect.new()
	visual.color = color
	visual.size = Vector2(size, size)
	visual.position = Vector2(-size / 2.0, -size / 2.0)
	pickup.add_child(visual)
	return pickup

func _ready() -> void:
	add_to_group("tongue_target")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if needs_tongue or collected:
		return
	if body.is_in_group("player"):
		collect(body)

# Called by the player's tongue.
func pull_to(player: Node2D) -> void:
	if collected:
		return
	var t := create_tween()
	t.tween_property(self, "global_position", player.global_position, 0.15)
	t.tween_callback(collect.bind(player))

func collect(player: Node2D) -> void:
	if collected:
		return
	collected = true
	match kind:
		"apple":
			_collect_apple()
		"blueberry":
			_give_effect(player, "haste", 6.0, "Szybkość!")
		"fly_agaric":
			_give_effect(player, "hallucination", 12.0, "Halucynacje!")
		"aloe":
			if player.has_method("remove_effect"):
				player.call("remove_effect", "hallucination")
			_give_effect(player, "regen", 6.0, "Regeneracja!")
		"flower":
			_give_effect(player, "strength", 10.0, "Siła!")
		"nettle":
			_give_effect(player, "poison", 5.0, "Zatrucie!")
	queue_free()

func _collect_apple() -> void:
	GameState.apples_collected += 1
	if not GameState.tongue_learned:
		GameState.tongue_learned = true
		DialogueBox.show_text([
			"* Nauczyłeś się używać długiego języka!",
			"* Wciśnij T, aby łapać przedmioty z daleka.",
		])
	else:
		_float_text("+1 jabłko")

func _give_effect(player: Node2D, effect_name: String, duration: float, text: String) -> void:
	if player.has_method("apply_effect"):
		player.call("apply_effect", effect_name, duration)
	_float_text(text)

func _float_text(text: String) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var label := Label.new()
	label.text = text
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.position = global_position + Vector2(-30, -30)
	scene.add_child(label)
	var t := label.create_tween()
	t.tween_property(label, "position:y", label.position.y - 24.0, 1.0)
	t.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	t.tween_callback(label.queue_free)
