extends Node2D

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var sprite = get_parent()

func start(duration, frequency, amp, pri):
	if (pri >= self.priority):
		self.priority = pri
		self.amplitude = amp

		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()

		_new_shake()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$Tween.interpolate_property(sprite, "offset", sprite.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$Tween.start()

func _reset():
	$Tween.interpolate_property(sprite, "offset", sprite.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$Tween.start()

	priority = 0

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
