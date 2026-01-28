extends TileMapLayer

@export_group('Grid Dimensions')
@export var grid_width: int = 20:
	set (value):
		grid_width = value
		_populate_grid()
@export var grid_height: int = 15:
	set (value):
		grid_height = value
		_populate_grid()
@export var cell_size: int = 32:
	set (value):
		cell_size = value
		_rebuild_tile_set()
		_populate_grid()
@export var border_width: int = 1:
	set (value):
		border_width = value
		_rebuild_tile_set()
		_populate_grid()

@onready var cursor: ReferenceRect = $HoverCursor

var hover_pos: Vector2i = Vector2i(-1, -1)

func _ready():
	_rebuild_tile_set()
	_populate_grid()
	RenderingServer.set_default_clear_color(ThemeManager.BACKGROUND)
	print("Grid Ready: ", grid_width, "x", grid_height)

func _rebuild_tile_set():
	if cursor:
		cursor.size = Vector2(cell_size, cell_size)

	if tile_set:
		var old_source: TileSetSource = tile_set.get_source(0)
		if old_source is TileSetAtlasSource:
			old_source.texture = null  # Free the old texture
	var img: Image = Image.create(cell_size * 2, cell_size, false, Image.FORMAT_RGBA8)

	# Background tile
	var rect_0: Rect2i = Rect2i(0, 0, cell_size, cell_size)
	img.fill_rect(rect_0, ThemeManager.BACKGROUND)
	_draw_border(img, rect_0, ThemeManager.GRID)

	# Selected tile
	var rect_1: Rect2i = Rect2i(cell_size, 0, cell_size, cell_size)
	img.fill_rect(rect_1, ThemeManager.FOCUS_B)
	_draw_border(img, rect_1, ThemeManager.GRID)

	var tex: ImageTexture = ImageTexture.create_from_image(img)
	var new_tile_set: TileSet = TileSet.new()
	new_tile_set.tile_size = Vector2i(cell_size, cell_size)

	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(cell_size, cell_size)
	source.create_tile(Vector2i(0, 0)) # Background
	source.create_tile(Vector2i(1, 0)) # Selected

	new_tile_set.add_source(source, 0)
	self.tile_set = new_tile_set

	print("Tile set rebuilt with cell size ", cell_size)

func _draw_border(img: Image, rect: Rect2i, color: Color):
	for i in border_width:
		img.fill_rect(Rect2i(rect.position.x + i, rect.position.y + i, rect.size.x - 2 * i, 1), color) # Top
		img.fill_rect(Rect2i(rect.position.x + i, rect.position.y + rect.size.y - 1 - i, rect.size.x - 2 * i, 1), color) # Bottom
		img.fill_rect(Rect2i(rect.position.x + i, rect.position.y + i, 1, rect.size.y - 2 * i), color) # Left
		img.fill_rect(Rect2i(rect.position.x + rect.size.x - 1 - i, rect.position.y + i, 1, rect.size.y - 2 * i), color) # Right

func _populate_grid():
	clear()
	for x in grid_width:
		for y in grid_height:
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func _process(_delta):
	if not cursor:
		return

	var current_map_pos: Vector2i = local_to_map(get_global_mouse_position())

	if _is_within_bounds(current_map_pos):
		if current_map_pos == hover_pos: return

		hover_pos = current_map_pos
		var cell_origin: Vector2 = map_to_local(current_map_pos) - (Vector2(cell_size, cell_size) / 2)
		cursor.move_to(cell_origin)

	elif cursor.is_active:
		cursor.fade_out()
		hover_pos = Vector2i(-1, -1)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var map_pos: Vector2i = local_to_map(get_local_mouse_position())
			if _is_within_bounds(map_pos):
				_toggle_selection(map_pos)

func _is_within_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func _toggle_selection(coords: Vector2i):
	var current_tile: Vector2i = get_cell_atlas_coords(coords)

	if current_tile == Vector2i(0, 0):
		set_cell(coords, 0, Vector2i(1, 0)) # Change to selected tile
	else:
		set_cell(coords, 0, Vector2i(0, 0)) # Change back to background tile
	queue_redraw()

func _get_cell_rect(coords: Vector2i) -> Rect2:
	var pos: Vector2 = map_to_local(coords) - (Vector2(cell_size, cell_size) / 2)
	return Rect2(pos, Vector2(cell_size, cell_size))
