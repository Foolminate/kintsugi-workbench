class_name Conductor
extends Node

signal stepped_forward(step: Step)
signal stepped_backward(step: Step)
signal timeline_updated(current_index: int, total_steps: int)
signal playback_finished()

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
    _is_playing = true
    timeline_updated.emit(_head, _trace.size())

func step(direction: int) -> bool:
    if direction == 1:
        if _head >= _trace.size() - 1:
            playback_finished.emit()
            return false
        _head += 1
        stepped_forward.emit(_trace[_head])
    else:
        if _head < 0: return false
        stepped_backward.emit(_trace[_head])
        _head -= 1
    timeline_updated.emit(_head, _trace.size())

    return true

func play_forward() -> void:
    _is_playing = true
    _playback_direction = 1

func play_backward() -> void:
    _is_playing = true
    _playback_direction = -1

func pause() -> void:
    _is_playing = false

func stop() -> void:
    _is_playing = false
    _head = -1
    timeline_updated.emit(_head, _trace.size())

func set_playback_speed(steps_per_second: float) -> void:
    _playback_speed = max(0.001, steps_per_second)

func update_trace(new_trace: Array[Step]) -> void:
    var limit = min(_trace.size(), new_trace.size())
    var divergence_index = limit

    # 1. Find where the traces diverge
    for i in limit:
        if not _trace[i].equals(new_trace[i]):
            divergence_index = i
            break

	# 2. If we are past the divergence, trigger visual rewind
    if _head >= divergence_index:
        _pending_trace = new_trace
        _rewind_target_index = divergence_index - 1
        _is_resolving_divergence = true
        _saved_speed = _playback_speed
        _playback_speed = max(_playback_speed, 50.0) # Accelerated rewind
        play_backward()
    else:
        _trace = new_trace
        timeline_updated.emit(_head, _trace.size())

func _stop_divergence_resolution() -> void:
    _is_resolving_divergence = false
    _playback_speed = _saved_speed
    _trace = _pending_trace
    timeline_updated.emit(_head, _trace.size())

func _process(delta: float) -> void:
    if not _is_playing: return

    _time_accumulator += delta
    var step_interval = 1.0 / _playback_speed

    while _time_accumulator >= step_interval:
        _time_accumulator -= step_interval

        if _is_resolving_divergence and _head <= _rewind_target_index:
            # Stop rewinding and switch to new trace
            _is_playing = false
            _is_resolving_divergence = false
            _playback_speed = _saved_speed
            _trace = _pending_trace
            timeline_updated.emit(_head, _trace.size())
            return

        if not step(_playback_direction):
            _is_playing = false
            break
