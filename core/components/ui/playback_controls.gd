extends PanelContainer

signal on_play_pressed()
signal on_pause_pressed()
signal on_stop_pressed()
signal on_rewind_pressed()
signal on_step_requested(index: int)
signal on_speed_changed(new_speed: float)

# Buttons
@onready var rewind_button: Button = %RewindButton
@onready var step_backward_button: Button = %StepBackwardButton
@onready var play_pause_button: Button = %PlayPauseButton
@onready var step_forward_button: Button = %StepForwardButton
@onready var fast_forward_button: Button = %FastForwardButton
@onready var stop_button: Button = %StopButton
# Timeline
@onready var elapsed_time_label: Label = %ElapsedTimeLabel
@onready var elapsed_frames_label: Label = %ElapsedFramesLabel
@onready var timeline_slider: HSlider = %TimelineSlider
@onready var total_time_label: Label = %TotalTimeLabel
@onready var total_frames_label: Label = %TotalFramesLabel
# Playback Speed
@onready var speed_selector: SpinBox = %SpeedSelector

@export var play_icon: Texture2D
@export var pause_icon: Texture2D

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
	total_frames_label.text = str(max_steps)

func update_current_step(index: int) -> void:
	timeline_slider.set_value_no_signal(index)
	elapsed_time_label.text = _format_time(index)
	elapsed_frames_label.text = str(index + 1)

func change_timeline_range(current_index: int, total_steps: int) -> void:
	timeline_slider.min_value = -1
	timeline_slider.max_value = total_steps - 1
	timeline_slider.set_value_no_signal(current_index)
	elapsed_time_label.text = _format_time(current_index)
	elapsed_frames_label.text = str(current_index + 1)
	total_time_label.text = _format_time(total_steps)
	total_frames_label.text = str(total_steps)

func _reverse() -> void:
	on_rewind_pressed.emit()
	rewind_button.release_focus()
	play_pause_button.set_pressed_no_signal(true)

func _step_backward() -> void:
	_pause()
	on_step_requested.emit(int(timeline_slider.value) - 1)
	step_backward_button.release_focus()

func _play() -> void:
	play_pause_button.icon = pause_icon
	play_pause_button.set_pressed_no_signal(true)
	play_pause_button.release_focus()

func _pause() -> void:
	play_pause_button.icon = play_icon
	play_pause_button.release_focus()
	play_pause_button.set_pressed_no_signal(false)

func _step_forward() -> void:
	_pause()
	on_step_requested.emit(int(timeline_slider.value) + 1)
	step_forward_button.release_focus()

func _fast_forward() -> void:
	speed_selector.value *= 2
	if not is_playing:
		on_play_pressed.emit()
		_play()
	fast_forward_button.release_focus()

func _stop() -> void:
	_pause()
	on_stop_pressed.emit()
	stop_button.release_focus()

func _ready() -> void:
	rewind_button.pressed.connect(_reverse)
	step_backward_button.pressed.connect(_step_backward)
	play_pause_button.pressed.connect(_on_play_pause_toggled)
	step_forward_button.pressed.connect(_step_forward)
	fast_forward_button.pressed.connect(_fast_forward)
	stop_button.pressed.connect(_stop)
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
