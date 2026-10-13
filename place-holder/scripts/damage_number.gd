class_name DamageNumber
extends Label

# true = rainbow cycle while flying, false = one random color per number
const RAINBOW := true

var start_pos := Vector2.ZERO
var side := 0.0
var hue := 0.0
var rainbow := false

static func spawn(parent: Node, pos: Vector2, amount: int, is_heal: bool = false) -> void:
	var label := DamageNumber.new()
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.custom_minimum_size = Vector2(40, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = pos - Vector2(20, 0)

	if is_heal:
		label.text = "+" + str(amount)
		label.self_modulate = Color(0.4, 1.0, 0.5)
	else:
		label.text = str(amount)
		label.hue = randf()
		label.rainbow = RAINBOW
		label.self_modulate = Color.from_hsv(label.hue, 0.75, 1.0)

	parent.add_child(label)
	label.start_pos = label.position
	label.side = randf_range(-18.0, 18.0)
	label.play()

func play() -> void:
	var t := create_tween()
	t.tween_method(_move, 0.0, 1.0, 0.7)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.5)
	t.tween_callback(queue_free)

func _move(p: float) -> void:
	position = start_pos + Vector2(side * p, -120.0 * p * (1.0 - p))

	# pop: starts big and shrinks to normal size in the first moments
	pivot_offset = size / 2.0
	var pop := 1.0 + 0.6 * clampf(1.0 - p / 0.2, 0.0, 1.0)
	scale = Vector2(pop, pop)

	if rainbow:
		self_modulate = Color.from_hsv(fposmod(hue + p, 1.0), 0.75, 1.0)
