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

func _init(
	p_type: Enums.StepType = Enums.StepType.GRID_UPDATE,
	p_target: Variant = Vector2i.ZERO,
	p_payload: Variant = null,
	p_undo_payload: Variant = null
) -> void:
	type = p_type
	target = p_target
	payload = p_payload
	undo_payload = p_undo_payload

## equals override for easy comparison
func equals(other: Step) -> bool:
	return (
		not (type != other.type
		or target != other.target
		or payload != other.payload
		or undo_payload != other.undo_payload)
	)
