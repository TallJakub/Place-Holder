extends CharacterBody2D

@export var speed: float = 150.0

func _physics_process(_delta: float) -> void:
	if DialogueBox.is_open:
		return
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
