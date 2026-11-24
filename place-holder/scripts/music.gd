extends AudioStreamPlayer

func _ready() -> void:
	bus = &"Music"  # bus is created by the Settings autoload (volume slider, UC_03)
	stream = preload("res://assets/tuffmuzyczka.wav")
	play()
