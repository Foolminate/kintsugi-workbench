class_name Orchestrator
extends Node

## The central hub connecting Logic (Solver), Data (Grid), and View (Visualizer).
## It manages the "Source of Truth" for the grid and coordinates the hot-swap workflow.

@onready var grid_visualizer: GridVisualizer = $GridVisualizer
@onready var conductor: Conductor = $Conductor

@export_group("Problem Configuration")
@export var solver_script: Script
@export var puzzle_input: PuzzleInput

var _solver: Solver
var _grid_data: Grid

func _ready() -> void:
	assert(grid_visualizer, "No GridVisualizer provided.")
	assert(conductor, "No Conductor provided.")
	assert(solver_script, "No solver script provided.")
	assert(puzzle_input, "No puzzle input provided.")

	_solver = solver_script.new()
	assert(_solver is Solver, "Solver script did not instantiate a Solver.")

	conductor.stepped_forward.connect(_on_conductor_stepped_forward)
	conductor.stepped_backward.connect(_on_conductor_stepped_backward)
	grid_visualizer.cell_clicked.connect(_on_grid_input)

	var initial_data = _solver.parse_input(puzzle_input.text)

	load_problem(initial_data)

## Loads a specific problem configuration.
## @param solver_instance: An instance of a class extending Solver.
## @param initial_grid: The starting state of the grid.
func load_problem(initial_grid: Grid) -> void:
	_grid_data = initial_grid

	# Initialize the visualizer with the raw state
	grid_visualizer.initialize_grid(_grid_data)

	# Run the initial solution
	_trigger_solve(true)

func _trigger_solve(is_initial_load: bool) -> void:
	if not _solver:
		return

	# In a real app, this might be run in a thread to avoid freezing the UI
	var new_trace = _solver.solve(_grid_data)

	if is_initial_load:
		conductor.load_trace(new_trace)
	else:
		conductor.update_trace(new_trace)

## Handles user input to modify the grid state.
func _on_grid_input(coords: Vector2i, button_index: int) -> void:
	# Example logic: Left click = Wall, Right click = Empty
	# In a real app, this mapping might be configurable via the Solver or a Tool
	var new_state = Enums.CellState.WALL
	if button_index == MOUSE_BUTTON_RIGHT:
		new_state = Enums.CellState.EMPTY

	# 1. Update the Source of Truth
	_grid_data.cells[coords] = new_state

	# 2. Update the View immediately (for responsiveness)
	if grid_visualizer:
		grid_visualizer.set_cell_state(coords, new_state)

	# 3. Trigger a background re-solve (Hot-Swap)
	_trigger_solve(false)

# --- Playback Handlers ---

func _on_conductor_stepped_forward(step: Step) -> void:
	_apply_step_visuals(step, false)

func _on_conductor_stepped_backward(step: Step) -> void:
	_apply_step_visuals(step, true)

func _apply_step_visuals(step: Step, is_undo: bool) -> void:
	if not grid_visualizer: return

	var value = step.undo_payload if is_undo else step.payload

	match step.type:
		Enums.StepType.GRID_UPDATE:
			grid_visualizer.set_cell_state(step.target, value)
		# Add other step types here (CAMERA_MOVE, etc.)
