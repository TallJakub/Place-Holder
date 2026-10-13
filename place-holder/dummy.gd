extends CharacterBody2D

@export var max_hp: int = 3
@export var knockback_strength: float = 160.0
@export var heal_delay: float = 4.0
@export var heal_interval: float = 0.5
@export var respawn_time: float = 8.0
@export var chase_speed: float = 45.0
@export var aggro_range: float = 140.0
@export var attack_range: float = 34.0
@export var contact_damage: int = 1
@export var attack_cooldown: float = 1.0

const BAR_WIDTH := 28.0

var hp: int
var dead := false
var spawn_point := Vector2.ZERO
var knockback := Vector2.ZERO
var base_color := Color.WHITE
var time_since_hit := 0.0
var heal_timer := 0.0
var stun := 0.0
var attack_timer := 0.0
var bar_root: Node2D
var bar_fill: ColorRect

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hp = max_hp
	spawn_point = global_position
	base_color = sprite.modulate
	add_to_group("enemies")
	_setup_health_bar()

func _setup_health_bar() -> void:
	bar_root = Node2D.new()
	bar_root.position = Vector2(-BAR_WIDTH / 2.0, -28)
	bar_root.visible = false

	var back := ColorRect.new()
	back.color = Color(0.1, 0.1, 0.1)
	back.size = Vector2(BAR_WIDTH, 5)
	bar_root.add_child(back)

	bar_fill = ColorRect.new()
	bar_fill.color = Color(0.9, 0.15, 0.15)
	bar_fill.position = Vector2(1, 1)
	bar_fill.size = Vector2(BAR_WIDTH - 2, 3)
	bar_root.add_child(bar_fill)

	add_child(bar_root)

func _update_bar() -> void:
	bar_fill.size.x = (BAR_WIDTH - 2) * float(hp) / float(max_hp)

func _physics_process(delta: float) -> void:
	if dead:
		return

	stun = maxf(stun - delta, 0.0)
	attack_timer = maxf(attack_timer - delta, 0.0)

	var chase := Vector2.ZERO
	var player = get_tree().get_first_node_in_group("player")
	if player != null and not GameState.dead and stun <= 0.0:
		var dist: float = global_position.distance_to(player.global_position)
		if dist < aggro_range:
			chase = (player.global_position - global_position).normalized() * chase_speed
		if dist < attack_range and attack_timer <= 0.0:
			attack_timer = attack_cooldown
			player.take_damage(contact_damage, global_position)

	velocity = chase + knockback
	knockback = knockback.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()

	time_since_hit += delta
	if hp < max_hp and time_since_hit >= heal_delay:
		heal_timer += delta
		if heal_timer >= heal_interval:
			heal_timer = 0.0
			_heal(1)

func _heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -20), amount, true)
	_update_bar()
	if hp >= max_hp:
		bar_root.visible = false

func take_damage(amount: int, from_position: Vector2) -> void:
	if dead:
		return
	hp = maxi(hp - amount, 0)
	time_since_hit = 0.0
	heal_timer = 0.0
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -20), amount)

	if hp <= 0:
		_die()
		return

	bar_root.visible = true
	_update_bar()

	stun = 0.25
	knockback = (global_position - from_position).normalized() * knockback_strength
	sprite.modulate = Color(1, 0.3, 0.3)
	var t := create_tween()
	t.tween_property(sprite, "modulate", base_color, 0.15)

func _die() -> void:
	dead = true
	bar_root.visible = false
	hide()
	collision.set_deferred("disabled", true)
	var t := create_tween()
	t.tween_interval(respawn_time)
	t.tween_callback(_respawn)

func _respawn() -> void:
	global_position = spawn_point
	hp = max_hp
	knockback = Vector2.ZERO
	stun = 0.0
	time_since_hit = 0.0
	heal_timer = 0.0
	_update_bar()
	modulate.a = 0.0
	show()
	collision.set_deferred("disabled", false)
	dead = false
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)
