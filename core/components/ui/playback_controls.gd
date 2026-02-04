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

var is_playing: bool = false

func set_playback_state(playing: bool) -> void:
	is_playing = playing
	play_pause_button.text = "Pause" if playing else "Play"
	play_pause_button.modulate = Color(1.5, 1.5, 1.5) if playing else Color(1, 1, 1)

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

func _ready() -> void:
	play_pause_button.pressed.connect(_on_play_pause_toggled)
	%StopButton.pressed.connect(func(): on_stop_pressed.emit())
	%RewindButton.pressed.connect(func(): on_rewind_pressed.emit())
	timeline_slider.value_changed.connect(func(value): on_step_requested.emit(int(value)))
	speed_selector.value_changed.connect(func(value: float): on_speed_changed.emit(value))

func _on_play_pause_toggled() -> void:
	if is_playing:
		on_pause_pressed.emit()
	else:
		on_play_pressed.emit()
