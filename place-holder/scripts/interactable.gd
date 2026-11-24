class_name Interactable
extends Area2D
# Invisible zone: when the player stands in it and presses "interact" (Space),
# the `interacted` signal fires. Used for NPCs, the tree trunk, the coop door...

signal interacted

var player_near := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = false

func _unhandled_input(event: InputEvent) -> void:
	if player_near and not DialogueBox.is_open and not GameState.dead \
			and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		interacted.emit()
