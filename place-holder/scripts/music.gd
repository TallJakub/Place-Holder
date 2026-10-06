extends AudioStreamPlayer

func _ready() -> void:
	stream = preload("res://assets/tuffmuzyczka.wav")
	play()
