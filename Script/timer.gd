extends Control

@onready var timer_label = $Timer_Label
@onready var timer = $Timer
var time_left = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		time_left = timer.time_left
	timer_label.text = str(int(time_left))
