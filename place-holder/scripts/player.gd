extends CharacterBody2D

@export var speed: float = 150.0
@export var attack_damage: int = 1

var facing := Vector2.DOWN
var attacking := false
var invulnerable := false
var knockback := Vector2.ZERO

# Temporary power-up (fruit) state
var speed_mult := 1.0
var bonus_damage := 0
var boost_tween: Tween

var hitbox: Area2D
var swing_visual: ColorRect

# Tongue (T): catches items that are far away (apples on branches...)
const TONGUE_RANGE := 110.0
var tongue_line: Line2D
var tongue_busy := false

# Timed effects from the plants on the clearing (UC_10): name -> seconds left.
# haste, strength, regen, poison, hallucination
var effects := {}
var effect_speed := 1.0
var effect_bonus := 0
var effect_tick := 0.0
var halluc_timer := 0.0
var halluc_layer: CanvasLayer
var halluc_rect: ColorRect
var phantoms: Array = []

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")
	if RoomManager.has_spawn:
		global_position = RoomManager.spawn_position
	_setup_hitbox()
	_setup_tongue()

func _setup_hitbox() -> void:
	hitbox = Area2D.new()
	hitbox.monitorable = false
	hitbox.monitoring = false

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 64)
	shape.shape = rect
	hitbox.add_child(shape)

	swing_visual = ColorRect.new()
	swing_visual.color = Color(1, 1, 1, 0.5)
	swing_visual.size = Vector2(64, 64)
	swing_visual.position = Vector2(-32, -32)
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
	velocity = direction * speed * speed_mult * effect_speed + knockback
	knockback = knockback.move_toward(Vector2.ZERO, 700.0 * delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not attacking \
			and not GameState.dead and not DialogueBox.is_open \
			and not RoomManager.transitioning:
		attack()
	elif event.is_action_pressed("tongue") and not tongue_busy \
			and not GameState.dead and not DialogueBox.is_open \
			and not RoomManager.transitioning:
		use_tongue()

func attack() -> void:
	attacking = true
	hitbox.position = facing * 36
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
		body.take_damage(attack_damage + bonus_damage + effect_bonus, global_position)

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

func apply_power_up(new_speed_mult: float, new_bonus_damage: int, duration: float) -> void:
	speed_mult = new_speed_mult
	bonus_damage = new_bonus_damage
	modulate = Color(1.0, 0.85, 0.4)  # gold glow

	if boost_tween:
		boost_tween.kill()  # picking up a second fruit restarts the timer
	boost_tween = create_tween()
	boost_tween.tween_interval(duration)
	boost_tween.tween_callback(_end_power_up)

func _end_power_up() -> void:
	speed_mult = 1.0
	bonus_damage = 0
	modulate = Color.WHITE

# ---------------------------------------------------------------------------
# Tongue (key T)
# ---------------------------------------------------------------------------
func _setup_tongue() -> void:
	tongue_line = Line2D.new()
	tongue_line.width = 3.0
	tongue_line.default_color = Color(0.95, 0.35, 0.5)
	tongue_line.top_level = true  # points are in world coordinates
	tongue_line.z_index = 50
	tongue_line.visible = false
	add_child(tongue_line)

func use_tongue() -> void:
	tongue_busy = true
	var target := _find_tongue_target()
	var tip := global_position + facing * TONGUE_RANGE
	if target != null:
		tip = target.global_position
	tongue_line.visible = true
	_update_tongue(0.0, tip)

	var t := create_tween()
	t.tween_method(_update_tongue.bind(tip), 0.0, 1.0, 0.12)
	t.tween_callback(_pull_target.bind(target))
	t.tween_interval(0.25)
	t.tween_callback(_end_tongue)

func _update_tongue(progress: float, tip: Vector2) -> void:
	tongue_line.clear_points()
	tongue_line.add_point(global_position)
	tongue_line.add_point(global_position.lerp(tip, progress))

func _pull_target(target) -> void:
	if is_instance_valid(target) and target.has_method("pull_to"):
		target.call("pull_to", self)

func _end_tongue() -> void:
	tongue_line.visible = false
	tongue_busy = false

# Nearest "tongue_target" in front of the player, within range and roughly in line.
func _find_tongue_target() -> Node2D:
	var best: Node2D = null
	var best_along := TONGUE_RANGE + 1.0
	for node in get_tree().get_nodes_in_group("tongue_target"):
		var candidate := node as Node2D
		if candidate == null:
			continue
		var rel := candidate.global_position - global_position
		var along := rel.dot(facing)
		if along <= 0.0 or along > TONGUE_RANGE:
			continue
		if absf(rel.cross(facing)) > 20.0:
			continue
		if along < best_along:
			best_along = along
			best = candidate
	return best

# ---------------------------------------------------------------------------
# Timed effects (plants, UC_10)
# ---------------------------------------------------------------------------
func apply_effect(effect_name: String, duration: float) -> void:
	effects[effect_name] = duration
	if effect_name == "hallucination":
		_start_hallucination()
	_recalc_effects()

func remove_effect(effect_name: String) -> void:
	if not effects.has(effect_name):
		return
	effects.erase(effect_name)
	if effect_name == "hallucination":
		_stop_hallucination()
	_recalc_effects()

func _recalc_effects() -> void:
	effect_speed = 1.5 if effects.has("haste") else 1.0
	effect_bonus = 2 if effects.has("strength") else 0

func _process(delta: float) -> void:
	if effects.is_empty():
		return
	effect_tick += delta
	var tick := effect_tick >= 1.0
	if tick:
		effect_tick -= 1.0
	for key in effects.keys():
		if not effects.has(key):
			continue
		effects[key] -= delta
		if tick:
			if key == "regen":
				GameState.heal(2)
			elif key == "poison":
				GameState.damage(2)
		if key == "hallucination":
			_flash_hallucination(delta)
		if effects[key] <= 0.0:
			remove_effect(key)

func _start_hallucination() -> void:
	_stop_hallucination()
	halluc_layer = CanvasLayer.new()
	halluc_layer.layer = 5
	halluc_rect = ColorRect.new()
	halluc_rect.size = get_viewport().get_visible_rect().size
	halluc_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	halluc_rect.color = Color(0.9, 0.2, 0.9, 0.2)
	halluc_layer.add_child(halluc_rect)
	add_child(halluc_layer)
	for i in 3:
		var phantom := Phantom.new()
		phantom.position = global_position + Vector2.from_angle(TAU * i / 3.0) * 70.0
		get_parent().add_child(phantom)
		phantoms.append(phantom)

func _stop_hallucination() -> void:
	if halluc_layer != null:
		halluc_layer.queue_free()
		halluc_layer = null
		halluc_rect = null
	for phantom in phantoms:
		if is_instance_valid(phantom):
			phantom.queue_free()
	phantoms.clear()

# Colours change a few times per second (not every frame - easier on the eyes).
func _flash_hallucination(delta: float) -> void:
	halluc_timer -= delta
	if halluc_timer <= 0.0 and halluc_rect != null:
		halluc_timer = 0.3
		halluc_rect.color = Color.from_hsv(randf(), 0.8, 1.0, 0.2)
