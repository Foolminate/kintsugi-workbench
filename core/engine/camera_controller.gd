extends Camera2D

@export_group("Settings")
@export var smoothing_factor: float = 0.15

@export_subgroup("Panning")
@export var pan_speed: float = 1000.0

@export_subgroup("Zooming")
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0
@export var zoom_step: float = 0.15

var _target_zoom: float = 1.0
var _target_position: Vector2 = Vector2.ZERO

func frame_rect(rect: Rect2, padding: float = 100.0) -> void:
	if rect.size == Vector2.ZERO:
		return

	# Use the actual viewport size from the SubViewport
	var viewport_size = get_viewport().get_visible_rect().size

	# Safety check: If the viewport hasn't initialized its size yet,
	# wait for the next frame or use a default.
	if viewport_size.x <= 2:
		await get_tree().process_frame
		viewport_size = get_viewport().get_visible_rect().size

	var usable_space = viewport_size - Vector2(padding, padding) * 2
	var zoom_x = usable_space.x / rect.size.x
	var zoom_y = usable_space.y / rect.size.y

	_target_zoom = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)
	_target_position = rect.get_center()
	set_process(true)

func frame_node(node: Node2D, padding: float = 100.0) -> void:
	var rect = Rect2()
	if node.has_method("get_rect"):
		var local_rect = node.get_rect()
		rect = node.get_global_transform() * local_rect
	frame_rect(rect, padding)
	set_process(true)

func _ready() -> void:
	_target_position = global_position
	_target_zoom = zoom.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_pan"):
		_target_position -= event.relative / zoom
		set_process(true)

	elif event.is_action_pressed("zoom_in"):
		_update_zoom(1.0 + zoom_step)

	elif event.is_action_pressed("zoom_out"):
		_update_zoom(1.0 - zoom_step)

	elif Input.get_vector("move_left", "move_right", "move_up", "move_down"):
		set_process(true)

func _update_zoom(factor: float) -> void:
	var old_zoom = _target_zoom
	_target_zoom = clamp(_target_zoom * factor, min_zoom, max_zoom)

	var mouse_pos = get_global_mouse_position()
	var zoom_ratio = old_zoom / _target_zoom
	_target_position = mouse_pos + (global_position - mouse_pos) * zoom_ratio
	set_process(true)

func _process(delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector:
		_target_position += input_vector * pan_speed * (1.0 / zoom.x) * delta

	var movement_weight = 1.0 - exp(-smoothing_factor * delta)
	global_position = global_position.lerp(_target_position, movement_weight)
	zoom = zoom.lerp(Vector2.ONE * _target_zoom, movement_weight)

	if (global_position.distance_to(_target_position) < 0.1
		and abs(zoom.x - _target_zoom) < 0.01
		and input_vector == Vector2.ZERO):
		global_position = _target_position
		zoom = Vector2.ONE * _target_zoom
		set_process(false)
