class_name Phantom
extends Node2D
# Hallucination (fly agaric, UC_10): a figure that chases the player and hits him.
# The player script frees all phantoms when the hallucination ends (aloe).

var speed := 40.0
var cooldown := 0.0

func _ready() -> void:
	z_index = 40
	var body := ColorRect.new()
	body.size = Vector2(14, 22)
	body.position = Vector2(-7, -11)
	body.color = Color(0.7, 0.3, 0.9, 0.7)
	add_child(body)

func _process(delta: float) -> void:
	if GameState.dead:
		return
	var target := get_tree().get_first_node_in_group("player") as Node2D
	if target == null:
		return
	cooldown = maxf(cooldown - delta, 0.0)
	var to_target := target.global_position - global_position
	if to_target.length() > 16.0:
		global_position += to_target.normalized() * speed * delta
	elif cooldown <= 0.0:
		cooldown = 1.0
		target.call("take_damage", 2, global_position)
