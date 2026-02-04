class_name Conductor
extends Node

signal on_stepped_forward(step: Step)
signal on_stepped_backward(step: Step)
signal on_timeline_changed(current_index: int, total_steps: int)
signal on_timeline_updated(current_index: int)
signal on_playback_finished()
signal on_playback_state_changed(is_playing: bool)
signal on_playback_speed_changed(new_speed: float)
signal on_divergence_resolution_started()
signal on_divergence_resolution_finished()

var DIVERGENCE_REWIND_TIME: float = 2.0 # seconds

var _trace: Array[Step] = []
var _head: int = -1
var _is_playing: bool = false
var _playback_speed: float = 20.0 # Steps per second
var _playback_direction: int = 1
var _time_accumulator: float = 0.0

var _pending_trace: Array[Step] = []
var _is_resolving_divergence: bool = false
var _rewind_target_index: int = -1
var _saved_speed: float = _playback_speed

func load_trace(trace: Array[Step]) -> void:
    _trace = trace
    _head = -1
    _is_playing = false
    on_playback_state_changed.emit(_is_playing)
    on_timeline_changed.emit(_head, _trace.size())

func step(direction: int) -> bool:
    if direction == 1:
        if _head >= _trace.size() - 1:
            on_playback_finished.emit()
            return false

        _head += 1
        on_stepped_forward.emit(_trace[_head])
    else:
        if _head < 0: return false

        on_stepped_backward.emit(_trace[_head])
        _head -= 1

    on_timeline_updated.emit(_head)

    return true

func play() -> void:
    _is_playing = true
    _playback_direction = 1
    on_playback_state_changed.emit(_is_playing)

func pause() -> void:
    _is_playing = false
    on_playback_state_changed.emit(_is_playing)

func stop() -> void:
    _is_playing = false
    seek(-1)
    on_timeline_updated.emit(_head)
    on_playback_state_changed.emit(_is_playing)

func rewind() -> void:
    _is_playing = true
    _playback_direction = -1
    on_playback_state_changed.emit(_is_playing)

func set_playback_speed(steps_per_second: float) -> void:
    _playback_speed = max(0.001, steps_per_second)

func seek(index: int) -> void:
    index = clamp(index, -1, _trace.size() - 1)
    while _head < index:
        step(1)
    while _head > index:
        step(-1)

func update_trace(new_trace: Array[Step]) -> void:
    var limit = min(_trace.size(), new_trace.size())
    var divergence_index = limit

    # 1. Find where the traces diverge
    for i in limit:
        if not _trace[i].equals(new_trace[i]):
            divergence_index = i
            break

	# 2. If we are past the divergence, rewind to before the trace was invalidated
    _is_resolving_divergence = _head >= divergence_index
    if _is_resolving_divergence:
        _start_divergence_resolution(divergence_index)
        _pending_trace = new_trace
    else:
        _trace = new_trace
        on_timeline_changed.emit(_head, _trace.size())

func _start_divergence_resolution(divergence_index: int) -> void:
    _rewind_target_index = divergence_index - 1
    var rewind_speed = ceil((_head - _rewind_target_index) / DIVERGENCE_REWIND_TIME) # Aim to rewind in ~2 seconds at 60fps
    _saved_speed = _playback_speed
    _playback_speed = max(_playback_speed, rewind_speed) # Accelerated rewind
    on_playback_speed_changed.emit(_playback_speed)

    on_divergence_resolution_started.emit()
    rewind()

func _stop_divergence_resolution() -> void:
    _is_resolving_divergence = false
    _playback_speed = _saved_speed
    on_playback_speed_changed.emit(_playback_speed)
    _trace = _pending_trace
    on_timeline_changed.emit(_head, _trace.size())
    on_divergence_resolution_finished.emit()
    play()

func _process(delta: float) -> void:
    if not _is_playing: return

    _time_accumulator += delta
    var step_interval = 1.0 / _playback_speed

    while _time_accumulator >= step_interval:
        _time_accumulator -= step_interval

        if _is_resolving_divergence and _head <= _rewind_target_index:
            # Stop on_rewinding and switch to new trace
            _stop_divergence_resolution()
            return

        if step(_playback_direction): continue

        pause()
