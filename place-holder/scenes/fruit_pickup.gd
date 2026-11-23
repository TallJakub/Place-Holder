extends Area2D

@export var speed_multiplier: float = 1.5
@export var bonus_damage: int = 1
@export var boost_duration: float = 8.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	body.apply_power_up(speed_multiplier, bonus_damage, boost_duration)
	queue_free()
