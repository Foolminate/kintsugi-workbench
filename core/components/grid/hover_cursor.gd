extends ReferenceRect

@export var follow_speed: float = 0.1
@export var pulse_max: float = 2.65
@export var pulse_min: float = 2.6
@export var pulse_speed: float = 1

var is_active: bool = false
var pulse_tween: Tween
var pulse_bright: Color = ThemeManager.FOCUS_A * pulse_max
var pulse_dim: Color = ThemeManager.FOCUS_A * pulse_min

func _ready() -> void:
	modulate.a = 0.0
	_start_pulsing()

func move_to(coords: Vector2) -> void:
	var move_tween: Tween = create_tween().set_parallel(true)
	if not is_active:
		is_active = true
		position = coords
		move_tween.tween_property(self, "modulate:a", 1.0, 0.1)
		pulse_tween.play()
		return

	move_tween.tween_property(self, "position", coords, follow_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func fade_out() -> void:
	is_active = false
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	pulse_tween.stop()

func _start_pulsing() -> void:
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(self, "self_modulate:v", pulse_max, pulse_speed).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(self, "self_modulate:v", pulse_min, pulse_speed).set_trans(Tween.TRANS_SINE)
