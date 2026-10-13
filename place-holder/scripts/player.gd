extends CharacterBody2D

@export var speed: float = 100.0
@export var attack_damage: int = 1

var facing := Vector2.DOWN
var attacking := false
var invulnerable := false
var knockback := Vector2.ZERO

var hitbox: Area2D
var swing_visual: ColorRect

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")
	if RoomManager.has_spawn:
		global_position = RoomManager.spawn_position
	_setup_hitbox()

func _setup_hitbox() -> void:
	hitbox = Area2D.new()
	hitbox.monitorable = false
	hitbox.monitoring = false

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(36, 36)
	shape.shape = rect
	hitbox.add_child(shape)

	swing_visual = ColorRect.new()
	swing_visual.color = Color(1, 1, 1, 0.5)
	swing_visual.size = Vector2(36, 36)
	swing_visual.position = Vector2(-18, -18)
	swing_visual.visible = false
	hitbox.add_child(swing_visual)

	hitbox.body_entered.connect(_on_hitbox_body_entered)
	add_child(hitbox)

func _physics_process(delta: float) -> void:
	if GameState.dead or DialogueBox.is_open or RoomManager.transitioning:
		return
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			facing = Vector2(sign(direction.x), 0)
		else:
			facing = Vector2(0, sign(direction.y))
	velocity = direction * speed + knockback
	knockback = knockback.move_toward(Vector2.ZERO, 700.0 * delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not attacking \
			and not GameState.dead and not DialogueBox.is_open \
			and not RoomManager.transitioning:
		attack()

func attack() -> void:
	attacking = true
	hitbox.position = facing * 28
	swing_visual.visible = true
	hitbox.set_deferred("monitoring", true)

	var t := create_tween()
	t.tween_interval(0.15)
	t.tween_callback(_end_swing)
	t.tween_interval(0.2)
	t.tween_callback(func(): attacking = false)

func _end_swing() -> void:
	hitbox.set_deferred("monitoring", false)
	swing_visual.visible = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(attack_damage, global_position)

func take_damage(amount: int, from_position: Vector2) -> void:
	if invulnerable or GameState.dead:
		return
	invulnerable = true
	knockback = (global_position - from_position).normalized() * 180.0
	GameState.damage(amount)

	sprite.modulate = Color(1, 0.35, 0.35)
	var t := create_tween()
	for i in 4:
		t.tween_property(sprite, "modulate:a", 0.3, 0.1)
		t.tween_property(sprite, "modulate:a", 1.0, 0.1)
	t.tween_callback(_end_invulnerable)

func _end_invulnerable() -> void:
	sprite.modulate = Color.WHITE
	invulnerable = false
