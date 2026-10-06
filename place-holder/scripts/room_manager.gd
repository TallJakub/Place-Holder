extends Node

var spawn_position := Vector2.ZERO
var has_spawn := false
var transitioning := false

var fade_rect: ColorRect

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0
	layer.add_child(fade_rect)

func change_room(scene_path: String, spawn: Vector2) -> void:
	if transitioning:
		return
	transitioning = true
	spawn_position = spawn
	has_spawn = true

	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "modulate:a", 1.0, 0.25)
	await fade_out.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame

	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, 0.25)
	await fade_in.finished
	transitioning = false
