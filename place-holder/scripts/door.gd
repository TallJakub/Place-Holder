extends Area2D

@export_file("*.tscn") var target_room: String
@export var spawn_position := Vector2(320, 240)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		RoomManager.change_room.call_deferred(target_room, spawn_position)
