class_name RoomBase
extends Node2D
# Base for the story rooms (kurnik, dwór, jabłoń, ...). Rooms are built in code
# (like the UI scripts already in the project), so every room scene is just a
# Node2D with a script. Subclasses override _build() and the small hooks below.

const ROOM_SIZE := Vector2(512, 256)
const PLAYER_SCENE := preload("res://scenes/player.tscn")

const KURNIK := "res://scenes/rooms/kurnik.tscn"
const DWOR := "res://scenes/rooms/dwor.tscn"
const JABLON := "res://scenes/rooms/jablon.tscn"
const KORONA := "res://scenes/rooms/korona.tscn"
const WODA := "res://scenes/rooms/woda.tscn"
const DNO := "res://scenes/rooms/dno.tscn"
const POLANA := "res://scenes/rooms/polana.tscn"

var player: CharacterBody2D

# --- hooks for subclasses ---------------------------------------------------
func _bg_color() -> Color:
	return Color(0.35, 0.65, 0.3)

func _player_start() -> Vector2:
	return Vector2(256, 128)

func _title() -> String:
	return ""

func _build() -> void:
	pass

# ----------------------------------------------------------------------------
func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = _bg_color()
	bg.size = ROOM_SIZE
	bg.z_index = -10
	add_child(bg)

	_add_walls()
	_build()

	player = PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = _player_start()
	player.scale = Vector2(0.5, 0.5)
	add_child(player)  # player.gd moves it to RoomManager.spawn_position if set

	if _title() != "":
		_show_title(_title())

func _add_walls() -> void:
	var walls := StaticBody2D.new()
	add_child(walls)
	_wall(walls, Vector2(256, -16), Vector2(512, 32))
	_wall(walls, Vector2(256, 272), Vector2(512, 32))
	_wall(walls, Vector2(-16, 128), Vector2(32, 256))
	_wall(walls, Vector2(528, 128), Vector2(32, 256))

func _wall(parent: Node, center: Vector2, size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = center
	parent.add_child(shape)

func _show_title(text: String) -> void:
	var label := add_text(text, Vector2(0, 8), 16)
	label.size = Vector2(ROOM_SIZE.x, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 90
	var t := label.create_tween()
	t.tween_interval(1.5)
	t.tween_property(label, "modulate:a", 0.0, 0.8)
	t.tween_callback(label.queue_free)

# --- building helpers --------------------------------------------------------
func add_rect(pos: Vector2, size: Vector2, color: Color, z: int = 0) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = size
	rect.color = color
	rect.z_index = z
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	return rect

# Solid obstacle (collision + optional visual). pos is the top-left corner.
func add_solid(pos: Vector2, size: Vector2, color: Color = Color(0, 0, 0, 0)) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = pos + size / 2.0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)
	if color.a > 0.0:
		add_rect(pos, size, color)
	return body

func add_text(text: String, pos: Vector2, font_size: int = 10, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func add_area(rect: Rect2) -> Area2D:
	var area := Area2D.new()
	area.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var shape_res := RectangleShape2D.new()
	shape_res.size = rect.size
	shape.shape = shape_res
	area.add_child(shape)
	add_child(area)
	return area

func add_interact(rect: Rect2) -> Interactable:
	var zone := Interactable.new()
	zone.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var shape_res := RectangleShape2D.new()
	shape_res.size = rect.size
	shape.shape = shape_res
	zone.add_child(shape)
	add_child(zone)
	return zone

# Room exit. The spawn point should lie a good distance away from the target
# room's own doors, otherwise the player would bounce straight back.
func add_door(rect: Rect2, target: String, spawn: Vector2, tint: Color = Color(1, 1, 1, 0.12)) -> Area2D:
	var door := Area2D.new()
	door.set_script(preload("res://scripts/door.gd"))
	door.set("target_room", target)
	door.set("spawn_position", spawn)
	door.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var shape_res := RectangleShape2D.new()
	shape_res.size = rect.size
	shape.shape = shape_res
	door.add_child(shape)
	add_child(door)
	if tint.a > 0.0:
		add_rect(rect.position, rect.size, tint, -5)
	return door
