extends PanelContainer

signal on_play_pressed()
signal on_pause_pressed()
signal on_stop_pressed()
signal on_rewind_pressed()
signal on_step_requested(index: int)
signal on_speed_changed(new_speed: float)

@onready var rewind_button: Button = %RewindButton
@onready var play_pause_button: Button = %PlayPauseButton
@onready var timeline_slider: HSlider = %TimelineSlider
@onready var speed_selector: SpinBox = %SpeedSelector
@onready var stop_button: Button = %StopButton

var is_playing: bool = false
var _glow: Color = Color(1, 1, 1)
var _normal: Color = Color(1, 1, 1)

func set_playback_state(playing: bool) -> void:
	is_playing = playing
	if playing: _play()
	else: _pause()

func set_playback_speed(speed: float) -> void:
	speed_selector.set_value_no_signal(speed)

func update_timeline_range(max_steps: int) -> void:
	timeline_slider.max_value = max_steps - 1

func update_current_step(index: int) -> void:
	timeline_slider.set_value_no_signal(index)

func change_timeline_range(current_index: int, total_steps: int) -> void:
	timeline_slider.min_value = -1
	timeline_slider.max_value = total_steps - 1
	timeline_slider.set_value_no_signal(current_index)

func _play() -> void:
	play_pause_button.text = "Pause"
	play_pause_button.modulate = _glow
	play_pause_button.release_focus()

func _pause() -> void:
	play_pause_button.text = "Play"
	play_pause_button.modulate = _normal
	rewind_button.modulate = _normal
	play_pause_button.release_focus()

func _stop() -> void:
	_pause()
	on_stop_pressed.emit()
	stop_button.release_focus()

func _reverse() -> void:
	rewind_button.modulate = _glow
	on_rewind_pressed.emit()
	rewind_button.release_focus()

func _timeline_focus() -> void:
	timeline_slider.modulate = _glow

func _timeline_unfocus() -> void:
	timeline_slider.modulate = _normal

func _ready() -> void:
	play_pause_button.pressed.connect(_on_play_pause_toggled)
	stop_button.pressed.connect(_stop)
	rewind_button.pressed.connect(_reverse)
	timeline_slider.focus_entered.connect(_timeline_focus)
	timeline_slider.focus_exited.connect(_timeline_unfocus)
	timeline_slider.value_changed.connect(func(value): on_step_requested.emit(int(value)))
	timeline_slider.drag_ended.connect(func(_v): timeline_slider.release_focus())
	speed_selector.value_changed.connect(func(value): on_speed_changed.emit(value))

	set_playback_state(is_playing)

func _on_play_pause_toggled() -> void:
	if is_playing:
		on_pause_pressed.emit()
		_pause()
	else:
		on_play_pressed.emit()
		_play()
