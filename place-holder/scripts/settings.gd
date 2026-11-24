extends Node
# Autoload "Settings": music / SFX volume (UC_03) and the extra input actions
# used by the story scenarios (T = tongue, R = breathe).

const SAVE_PATH := "user://settings.cfg"

var music_volume := 0.8  # 0.0 .. 1.0
var sfx_volume := 0.8    # 0.0 .. 1.0

func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_add_key_action("tongue", KEY_T)
	_add_key_action("breathe", KEY_R)
	load_settings()
	apply()

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")

func _add_key_action(action: String, keycode: Key) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func apply() -> void:
	_apply_bus("Music", music_volume)
	_apply_bus("SFX", sfx_volume)

func _apply_bus(bus_name: String, volume: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_mute(index, volume <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.001)))

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	music_volume = clampf(float(cfg.get_value("audio", "music", music_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(cfg.get_value("audio", "sfx", sfx_volume)), 0.0, 1.0)
