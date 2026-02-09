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

## Main execution method.
##
## [param grid_data]: A Grid representing the initial state of the world.
## [return]: An Array of Step resources representing the execution history.
func solve(_grid_data: Grid) -> Array[Step]:
	push_error("Solver.solve() is abstract and must be implemented by the child class.")
	return []

## Helper to create a standardized Step.
func create_step(type: Enums.StepType, target: Variant, new_val: Variant, old_val: Variant, meta: Dictionary = {}) -> Step:
	return Step.new(type, target, new_val, old_val, meta)
