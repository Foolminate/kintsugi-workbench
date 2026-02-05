class_name Orchestrator
extends Node

## The central hub connecting Logic (Solver), Data (Grid), and View (Visualizer).
## It manages the "Source of Truth" for the grid and coordinates the hot-swap workflow.

@onready var camera: Camera2D = $Camera2D
@onready var grid_visualizer: GridVisualizer = $GridVisualizer
@onready var conductor: Conductor = $Conductor
@onready var playback_controls: PanelContainer = %PlaybackControls

@export_group("Configuration")
@export var solver_script: Script
@export var puzzle_input: PuzzleInput
@export var settings: DefaultSettings

var _solver: Solver
var _grid_data: Grid
var _is_resolving_divergence: bool = false

func _ready() -> void:
	assert(camera, "No Camera2D provided.")
	assert(grid_visualizer, "No GridVisualizer provided.")
	assert(conductor, "No Conductor provided.")
	assert(solver_script, "No solver script provided.")
	assert(puzzle_input, "No puzzle input provided.")
	assert(settings, "No DefaultSettings resource provided.")

	_solver = solver_script.new()
	assert(_solver is Solver, "Solver script did not instantiate a Solver.")

	conductor.on_stepped_forward.connect(_on_conductor_stepped_forward)
	conductor.on_stepped_backward.connect(_on_conductor_stepped_backward)
	conductor.on_divergence_resolution_started.connect(func(): _is_resolving_divergence = true)
	conductor.on_divergence_resolution_finished.connect(func(): _is_resolving_divergence = false)
	conductor.on_timeline_changed.connect(func(current_index, total_steps): playback_controls.change_timeline_range(current_index, total_steps))
	conductor.on_timeline_updated.connect(func(current_index): playback_controls.update_current_step(current_index))
	conductor.on_playback_state_changed.connect(func(is_playing): playback_controls.set_playback_state(is_playing))
	conductor.on_playback_speed_changed.connect(func(new_speed): playback_controls.set_playback_speed(new_speed))

	playback_controls.on_play_pressed.connect(conductor.play)
	playback_controls.on_pause_pressed.connect(conductor.pause)
	playback_controls.on_stop_pressed.connect(conductor.stop)
	playback_controls.on_rewind_pressed.connect(conductor.rewind)
	playback_controls.on_step_requested.connect(func(index): conductor.seek(index))
	playback_controls.on_speed_changed.connect(func(speed): conductor.set_playback_speed(speed))

	grid_visualizer.cell_clicked.connect(_on_grid_input)

	playback_controls.set_playback_speed(settings.playback_speed)
	conductor.set_playback_speed(settings.playback_speed)
	conductor.set_resume_after_rewind(settings.auto_play_new_trace)
	conductor.set_default_rewind_time(settings.rewind_time)

	# frame the grid_visualizer on screen resize
	get_tree().root.size_changed.connect(func(): camera.frame_node(grid_visualizer, 100.0, 0.5))
	var initial_data = _solver.parse_input(puzzle_input.text)

	load_problem(initial_data)

## Loads a specific problem configuration.
## @param solver_instance: An instance of a class extending Solver.
## @param initial_grid: The starting state of the grid.
func load_problem(initial_grid: Grid) -> void:
	_grid_data = initial_grid

	# Initialize the visualizer with the raw state
	grid_visualizer.initialize_grid(_grid_data)
	camera.frame_node(grid_visualizer, 100.0, 0.5)

	# Run the initial solution
	_trigger_solve(true)

func _trigger_solve(is_initial_load: bool) -> void:
	if not _solver:
		return

	# In a real app, this might be run in a thread to avoid freezing the UI
	var grid_copy = _clone_grid(_grid_data)
	var new_trace = _solver.solve(grid_copy)

	if is_initial_load:
		conductor.load_trace(new_trace)
	else:
		conductor.update_trace(new_trace)

## Handles user input to modify the grid state.
func _on_grid_input(coords: Vector2i, button_index: int) -> void:
	# Left click = Wall, Right click = Empty
	# TODO: make this configurable
	var new_state = Enums.CellState.WALL
	if button_index == MOUSE_BUTTON_RIGHT:
		new_state = Enums.CellState.EMPTY

	# 1. Update the Source of Truth
	_grid_data.cells[coords] = new_state

	# 2. Update the View
	if grid_visualizer:
		grid_visualizer.set_cell_state(coords, new_state)

	# 3. Re-solve in the background and hot-swap
	_trigger_solve(false)

func _clone_grid(source: Grid) -> Grid:
	var new_grid = Grid.new(source.width, source.height)
	new_grid.start = source.start
	new_grid.end = source.end
	new_grid.cells = source.cells.duplicate()
	return new_grid

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
			# If the user has placed a wall, prevent the trace (undo or redo) from overwriting it.
			if _is_resolving_divergence:
				if _grid_data.cells.get(step.target, Enums.CellState.EMPTY) == Enums.CellState.WALL and value != Enums.CellState.WALL:
					return

			grid_visualizer.set_cell_state(step.target, value)
		# Add other step types here (CAMERA_MOVE, etc.)
