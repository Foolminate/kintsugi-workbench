class_name Grid
extends Resource

## A standardized container for grid-based problem data.
## Stores the raw cell state, dimensions, and key points of interest.

var width: int = 0
var height: int = 0
var cells: Dictionary = {} # Key: Vector2i, Value: Enums.CellState (int)

var start: Vector2i = Vector2i(-1, -1)
var end: Vector2i = Vector2i(-1, -1)

func _init(p_width: int = 0, p_height: int = 0) -> void:
	width = p_width
	height = p_height

func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height