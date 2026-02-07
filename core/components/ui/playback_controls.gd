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
@onready var elapsed_time_label: Label = %ElapsedTimeLabel
@onready var total_time_label: Label = %TotalTimeLabel

var is_playing: bool = false

func set_playback_state(playing: bool) -> void:
	is_playing = playing
	if playing: _play()
	else: _pause()

func set_playback_speed(speed: float) -> void:
	speed_selector.set_value_no_signal(speed)

func update_timeline_range(max_steps: int) -> void:
	timeline_slider.max_value = max_steps - 1
	total_time_label.text = _format_time(max_steps)

func update_current_step(index: int) -> void:
	timeline_slider.set_value_no_signal(index)
	elapsed_time_label.text = _format_time(index)

func change_timeline_range(current_index: int, total_steps: int) -> void:
	timeline_slider.min_value = -1
	timeline_slider.max_value = total_steps - 1
	timeline_slider.set_value_no_signal(current_index)
	elapsed_time_label.text = _format_time(current_index)
	total_time_label.text = _format_time(total_steps)

func _play() -> void:
	play_pause_button.text = "Pause"
	play_pause_button.set_pressed_no_signal(true)
	play_pause_button.release_focus()

func _pause() -> void:
	play_pause_button.text = "Play"
	play_pause_button.release_focus()
	play_pause_button.set_pressed_no_signal(false)

func _stop() -> void:
	_pause()
	on_stop_pressed.emit()
	stop_button.release_focus()

func _reverse() -> void:
	on_rewind_pressed.emit()
	rewind_button.release_focus()
	play_pause_button.set_pressed_no_signal(true)

func _ready() -> void:
	play_pause_button.pressed.connect(_on_play_pause_toggled)
	stop_button.pressed.connect(_stop)
	rewind_button.pressed.connect(_reverse)
	timeline_slider.value_changed.connect(func(value): on_step_requested.emit(int(value)))
	timeline_slider.drag_ended.connect(func(_v): timeline_slider.release_focus())
	speed_selector.value_changed.connect(func(value): _on_speed_changed(value))

	set_playback_state(is_playing)

func _on_play_pause_toggled() -> void:
	if is_playing:
		on_pause_pressed.emit()
		_pause()
	else:
		on_play_pressed.emit()
		_play()

func _on_speed_changed(value: float) -> void:
	on_speed_changed.emit(value)
	elapsed_time_label.text = _format_time(int(timeline_slider.value))
	total_time_label.text = _format_time(int(timeline_slider.max_value))

func _format_time(step: int) -> String:
	var total_seconds = int((step + 1) / speed_selector.value)
	@warning_ignore("integer_division")
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
