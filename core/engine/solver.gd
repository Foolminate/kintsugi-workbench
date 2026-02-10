## Stateless base class for all algorithm solvers.
## Input Data -> Output Trace.
##
## This Resource combines the logic and manifest into a single "solver package".
## Tightly coupling solver implementations with their API.
class_name Solver
extends Resource

## The parameters and metadata definitions for this solver, used by the UI and MetadataHUD.
@export var manifest: SolverManifest

## Parses raw text input into the standardized Grid Data dictionary.
##
## This allows the Orchestrator to load a problem from a text file.
## @param input_text: The raw string from the puzzle input file.
## @return: A Dictionary { Vector2i: Enums.CellState }
func parse_input(_input_text: String) -> Grid:
	push_error("Solver.parse_input() is abstract and must be implemented by the child class.")
	return null

# --- Internal State ---
var _recorder: MetaRecorder
var _steps: Array[Step] = []


## Main execution method that runs the solver logic and produces a trace of steps.
## This is a template method that should not be overriden. Override _run() instead.
##
## [param grid_data]: A Grid representing the initial state of the world.
## [return]: An Array of Step resources representing the execution history.
func solve(_grid_data: Grid) -> Trace:
	# Initialize
	_recorder = MetaRecorder.new(manifest)
	_steps.clear()

	# Execute
	_run(_grid_data)

	# Package
	var trace = Trace.new()
	trace.steps = _steps
	trace.metadata = _recorder.flush()
	return trace

# The Unified Commit: Records both the Visual Delta and the Data State.
## [param type]: The visual action (MODIFY, POINTER, etc).
## [param target]: The grid coordinate (Vector2i).
## [param new_val]: The new cell state.
## [param old_val]: The previous cell state (for undo).
## [param meta]: An Array of values matching the order of 'manifest.metrics'.
func commit_step(type: Enums.StepType, target: Variant, new_val: Variant, old_val: Variant, meta: Array) -> void:
	_steps.append(Step.new(type, target, new_val, old_val))
	_recorder.record(meta)

## Override this method to implement the solver logic. Use commit_step() to record steps.
func _run(_grid_data: Grid) -> void:
	push_error("Solver._run() is abstract and must be implemented by the child class.")
