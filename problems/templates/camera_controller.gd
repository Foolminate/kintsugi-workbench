extends Camera2D

@export_group("Zoom Settings")
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0
@export var zoom_speed: float = 0.15
@export var zoom_duration: float = 0.2

var _target_zoom: float = 1.0
var _zoom_tween: Tween

func frame_rect(rect: Rect2, padding: float = 100.0, duration: float = zoom_duration) -> void:
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

	if _zoom_tween: _zoom_tween.kill()
	_zoom_tween = create_tween().set_parallel(true)
	_zoom_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * _target_zoom, duration)
	_zoom_tween.tween_property(self, "global_position", rect.get_center(), duration)

func frame_node(node: Node2D, padding: float = 100.0, duration: float = zoom_duration) -> void:
	var rect = Rect2()
	if node.has_method("get_rect"):
		var local_rect = node.get_rect()
		rect = node.get_global_transform() * local_rect
	frame_rect(rect, padding, duration)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_pan"):
			global_position -= event.relative / zoom
	elif event is InputEventMouseButton:
		if event.is_action_pressed("zoom_in"):
			_zoom_camera(1.0 + zoom_speed, get_global_mouse_position())
		elif event.is_action_pressed("zoom_out"):
			_zoom_camera(1.0 - zoom_speed, get_global_mouse_position())

func _zoom_camera(factor: float, focus_point: Vector2) -> void:
	_target_zoom = clamp(zoom.x * factor, min_zoom, max_zoom)

	var next_zoom = Vector2.ONE * _target_zoom
	var zoom_ratio = zoom.x / next_zoom.x
	var target_pos = global_position + (focus_point - global_position) * (1.0 - zoom_ratio)

	if _zoom_tween: _zoom_tween.kill()
	_zoom_tween = create_tween().set_parallel(true)
	_zoom_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * _target_zoom, zoom_duration)
	_zoom_tween.tween_property(self, "global_position", target_pos, zoom_duration)
