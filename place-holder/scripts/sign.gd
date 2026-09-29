extends StaticBody2D

var player_near := false

@onready var zone: Area2D = $InteractZone

func _ready() -> void:
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = false

func _unhandled_input(event: InputEvent) -> void:
	if player_near and not DialogueBox.is_open and event.is_action_pressed("interact"):
		interact()
		get_viewport().set_input_as_handled()

func interact() -> void:
	DialogueBox.show_text([
		"* Hello! This is a sign.",
		"* It doesn't say anything useful.",
	])
