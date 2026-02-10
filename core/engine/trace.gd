class_name Trace
extends Resource

## Ordered array of algorithm steps, representing the execution history of a solver.
var steps: Array[Step] = []

## Columnar metadata for each step.
## Format: {"metric_name": Packed*Array}
var metadata: Dictionary = {}
