class_name Step
extends Resource

## The type of command this step represents.
@export var type: Enums.StepType

## The target identifier (e.g., Vector2i for grid coordinates).
@export var target: Variant

## The new value to apply (e.g., Enums.CellState.VISITED).
@export var payload: Variant

## The previous value, used for reversing this step (Time-travel).
@export var undo_payload: Variant

## Optional data for UI details (costs, weights, debug info).
@export var metadata: Dictionary = {}

func _init(
	p_type: Enums.StepType = Enums.StepType.GRID_UPDATE,
	p_target: Variant = Vector2i.ZERO,
	p_payload: Variant = null,
	p_undo_payload: Variant = null,
	p_metadata: Dictionary = {}
) -> void:
	type = p_type
	target = p_target
	payload = p_payload
	undo_payload = p_undo_payload
	metadata = p_metadata

## equals override for easy comparison
func equals(other: Step) -> bool:
	return (
		type == other.type
		and target == other.target
		and payload == other.payload
		and undo_payload == other.undo_payload
	)
