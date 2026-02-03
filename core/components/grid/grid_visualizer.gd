class_name GridVisualizer
extends TileMapLayer

signal cell_clicked(coords: Vector2i, button_index: int)

@onready var cursor: ReferenceRect = $HoverCursor

@export_group("Grid Appearance")
@export var grid: Grid
@export var cell_size: int = 32
@export var border_width: int = 1

## Debug configuration for editor-based testing
@export_group("Debug")
@export var debug_create_on_ready: bool = false
@export var debug_size: Vector2i = Vector2i(10, 10)

var _hover_pos: Vector2i = Vector2i(-1, -1)

func get_rect() -> Rect2:
	var map_rect = get_used_rect()

	return Rect2(map_rect.position * cell_size, map_rect.size * cell_size)

func _ready():
	_rebuild_tile_set()

	if debug_create_on_ready:
		var debug_grid = Grid.new(debug_size.x, debug_size.y)
		initialize_grid(debug_grid)
		print("Grid Ready: ", debug_size.x, "x", debug_size.y)

func initialize_grid(new_grid: Grid = null) -> void:
	clear()
	if not new_grid and not grid:
		push_error("No grid provided to initialize_grid")
		return
	elif new_grid:
		grid = new_grid

	for y in range(grid.height):
		for x in range(grid.width):
			var coords = Vector2i(x, y)
			var state = grid.cells.get(coords, Enums.CellState.EMPTY)
			set_cell_state(coords, state)

func set_cell_state(coords: Vector2i, state: Enums.CellState) -> void:
	var atlas_coords = _get_atlas_coords(state)
	set_cell(coords, 0, atlas_coords)

func _get_atlas_coords(state: Enums.CellState) -> Vector2i:
	match state:
		Enums.CellState.EMPTY: 		return Vector2i(0, 0)
		Enums.CellState.WALL: 		return Vector2i(1, 0)
		Enums.CellState.START: 		return Vector2i(2, 0)
		Enums.CellState.END: 		return Vector2i(3, 0)
		Enums.CellState.VISITED: 	return Vector2i(4, 0)
		Enums.CellState.QUEUED: 	return Vector2i(5, 0)
		Enums.CellState.PROCESSING: return Vector2i(6, 0)
		Enums.CellState.ACTIVE: 	return Vector2i(7, 0)
	return Vector2i(0, 0)

func _rebuild_tile_set():
	if cursor:
		cursor.size = Vector2(cell_size, cell_size)

	if tile_set:
		var old_source: TileSetSource = tile_set.get_source(0)
		if old_source is TileSetAtlasSource:
			old_source.texture = null  # Free the old texture

	var states = Enums.CellState.values()
	var img: Image = Image.create(cell_size * states.size(), cell_size, false, Image.FORMAT_RGBA8)

	for state in states:
		var rect = Rect2i(state * cell_size, 0, cell_size, cell_size)
		img.fill_rect(rect, _get_state_color(state))
		_draw_border(img, rect, ThemeManager.GRID)

	var tex: ImageTexture = ImageTexture.create_from_image(img)
	var new_tile_set: TileSet = TileSet.new()
	new_tile_set.tile_size = Vector2i(cell_size, cell_size)

	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(cell_size, cell_size)

	for state in states:
		source.create_tile(Vector2i(state, 0))

	new_tile_set.add_source(source, 0)
	self.tile_set = new_tile_set

	print("Tile set rebuilt with cell size ", cell_size)

func _draw_border(img: Image, rect: Rect2i, color: Color):
	for i in border_width:
		img.fill_rect(Rect2i(rect.position.x + i, rect.position.y + i, rect.size.x - 2 * i, 1), color) # Top
		img.fill_rect(Rect2i(rect.position.x + i, rect.position.y + rect.size.y - 1 - i, rect.size.x - 2 * i, 1), color) # Bottom
		img.fill_rect(Rect2i(rect.position.x + i, rect.position.y + i, 1, rect.size.y - 2 * i), color) # Left
		img.fill_rect(Rect2i(rect.position.x + rect.size.x - 1 - i, rect.position.y + i, 1, rect.size.y - 2 * i), color) # Right

func _get_state_color(state: Enums.CellState) -> Color:
	match state:
		Enums.CellState.EMPTY: 		return ThemeManager.BACKGROUND
		Enums.CellState.WALL: 		return ThemeManager.GRID
		Enums.CellState.START: 		return ThemeManager.GREEN
		Enums.CellState.END: 		return ThemeManager.RED
		Enums.CellState.VISITED: 	return ThemeManager.BLUE
		Enums.CellState.QUEUED: 	return ThemeManager.PURPLE
		Enums.CellState.PROCESSING: return ThemeManager.ORANGE
		Enums.CellState.ACTIVE: 	return ThemeManager.YELLOW
		_: return ThemeManager.BACKGROUND

func _process(_delta):
	if not cursor or not grid:
		return

	var current_map_pos: Vector2i = local_to_map(get_global_mouse_position())

	if grid.is_in_bounds(current_map_pos):
		if current_map_pos == _hover_pos: return

		_hover_pos = current_map_pos
		var cell_origin: Vector2 = map_to_local(current_map_pos) - (Vector2(cell_size, cell_size) / 2)
		cursor.move_to(cell_origin)

	elif cursor.is_active:
		cursor.fade_out()
		_hover_pos = Vector2i(-1, -1)

func _input(event):
	if not grid: return

	if not event is InputEventMouseButton or not event.pressed: return
	if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
		var map_pos: Vector2i = local_to_map(get_local_mouse_position())
		if grid.is_in_bounds(map_pos):
			cell_clicked.emit(map_pos, event.button_index)
