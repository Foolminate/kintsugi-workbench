class_name MetricDefinition
extends Resource

## The user-friendly name for this metric (e.g., "Queue Size").
@export var label: String = ""

## The expected data type of the metric's value (e.g., TYPE_INT, TYPE_FLOAT).
@export var type: Variant.Type = TYPE_NIL

## A hint for the UI on how to best display this metric.
@export_enum("Text", "Graph", "Bar") var display_hint: String = "Text"

## (Optional) A suggested color for visualizations like graphs or bars.
@export_enum("RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "PURPLE", "WHITE") var color: String = "WHITE"
