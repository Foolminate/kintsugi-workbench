class_name ParameterDefinition
extends Resource

## The data type of the parameter, used by the UI factory to create the correct control.
## (e.g., TYPE_INT, TYPE_FLOAT, TYPE_BOOL)
@export var name: String = ""

@export var type: Variant.Type = TYPE_NIL

## The default value for this parameter.
@export var default_value: Variant

## (Optional) For numeric types, the minimum allowed value. Used for sliders/spinboxes.
@export var minimum: Variant

## (Optional) For numeric types, the maximum allowed value. Used for sliders/spinboxes.
@export var maximum: Variant

## (Optional) For numeric types, the step increment. Used for sliders/spinboxes.
@export var step: Variant

## (Optional) For string or int types, a list of allowed options. Used for OptionButton.
@export var options: Array = []
