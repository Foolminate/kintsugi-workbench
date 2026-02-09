
class_name SolverManifest
extends Resource

## A dictionary defining the parameters the solver accepts.
## The UI will be generated from this.
##
## The keys are the parameter names (e.g., "turn_cost") and the values
## are ParameterDefinition resources that describe the parameter.
@export var parameters: Dictionary[String, ParameterDefinition] = {}

## A dictionary defining global metrics the solver reports at each step.
## The MetadataHUD will display these.
##
## The keys are the metric keys (e.g., "queue_size") and the values are
## MetricDefinition resources that describe how to display the metric.
@export var global_metrics: Dictionary[String, MetricDefinition] = {}

## An ordered array defining the data stored per-cell (spatial).
## The Tooltip will display this on hover.
##
## Format: [{"label": "Display Name", "type": TYPE_*}]
## Example: [{"label": "G-Cost", "type": TYPE_INT}, {"label": "H-Cost", "type": TYPE_INT}].
@export var spatial_columns: Array[MetricDefinition] = []
