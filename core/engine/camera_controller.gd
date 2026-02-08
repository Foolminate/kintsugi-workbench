extends Camera2D

@export_group("Settings")
@export var smoothing_factor: float = 15.0

@export_subgroup("Panning")
@export var pan_speed: float = 1000.0

@export_subgroup("Zooming")
@export var min_zoom: float = 0.01
@export var max_zoom: float = 10.0
@export var zoom_step: float = 0.15

var _target_zoom: float = 1.0
var _target_position: Vector2 = Vector2.ZERO

func frame_rect(rect: Rect2, bottom_offset: float = 0.0, padding: float = 20.0) -> void:
	if rect.size == Vector2.ZERO:
		return

	# Use the root viewport size to ensure framing works even if the camera is in a SubViewport.
	var viewport_size = get_tree().root.get_visible_rect().size

	# Safety check: If the viewport hasn't initialized its size yet,
	# wait for the next frame or use a default.
	if viewport_size.x <= 2:
		print("Warning: Viewport size not initialized. Awaiting next frame.")
		await get_tree().process_frame
		viewport_size = get_tree().root.get_visible_rect().size

	var usable_space = viewport_size - Vector2(padding, padding) * 2.0
	# Account for the vertical space taken by the UI bar at the bottom.
	usable_space.y -= bottom_offset

	var zoom_x = usable_space.x / rect.size.x
	var zoom_y = usable_space.y / rect.size.y

	_target_zoom = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)

	# To center the grid in the usable area (above the UI), we must shift the
	# camera's target position. A positive Y offset moves the camera down, making
	# the content appear higher on screen.
	var world_y_offset = bottom_offset / (2.0 * _target_zoom)
	_target_position = rect.get_center() + Vector2(0, world_y_offset)

func frame_node(node: CanvasItem, bottom_offset: float = 0.0, padding: float = 20.0) -> void:
	var rect: Rect2
	if node.has_method("get_rect"):
		var local_rect = node.get_rect()
		rect = node.get_global_transform() * local_rect
	frame_rect(rect, bottom_offset, padding)
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
