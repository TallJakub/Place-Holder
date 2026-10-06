extends CharacterBody2D

@export var speed: float = 100.0

func _physics_process(_delta: float) -> void:
	if DialogueBox.is_open or RoomManager.transitioning:
		return
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
func _ready() -> void:
	if RoomManager.has_spawn:
		global_position = RoomManager.spawn_position
