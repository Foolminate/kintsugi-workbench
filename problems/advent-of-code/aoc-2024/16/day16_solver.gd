extends Solver
# TODO: Reimplement with C# for better performance
class SearchNode:
	var pos: Vector2i
	var dir: Vector2i
	var cost: int
	var parent: SearchNode

	func _init(p_pos: Vector2i, p_dir: Vector2i, p_cost: int, p_parent: SearchNode = null):
		pos = p_pos
		dir = p_dir
		cost = p_cost
		parent = p_parent

func parse_input(_input_text: String) -> Grid:
	var lines = _input_text.split("\n", false)
	var h = lines.size()
	var w = lines[0].length() if h > 0 else 0

	var grid = Grid.new(w, h)

	for y in range(h):
		var line = lines[y]
		for x in range(w):
			var cell = line[x]
			var state = Enums.CellState.EMPTY
			var pos = Vector2i(x, y)
			match cell:
				"S":
					state = Enums.CellState.START
					grid.start = pos
				"E":
					state = Enums.CellState.END
					grid.end = pos
				"#": state = Enums.CellState.WALL
			grid.cells[pos] = state

	return grid

func _run(grid: Grid) -> void:
	var pq = PriorityQueue.new()
	var visited: Dictionary = {} # Key: Vector3i(x, y, dir_idx), Value: cost

	# Start facing East (1, 0)
	var start_dir = Vector2i.RIGHT
	var start_node = SearchNode.new(grid.start, start_dir, 0)
	pq.push(0, start_node)
	var depth: int = 1

	var final_node: SearchNode = null

	while not pq.is_empty():
		var current: SearchNode = pq.pop()
		depth = pq.depth()

		var dir_idx = _get_dir_index(current.dir)
		var state_key = Vector3i(current.pos.x, current.pos.y, dir_idx)

		if visited.has(state_key) and visited[state_key] <= current.cost:
			continue
		visited[state_key] = current.cost

		# Trace: Current
		var current_state = grid.cells.get(current.pos, Enums.CellState.EMPTY)
		commit_step(Enums.StepType.GRID_UPDATE, current.pos, [Enums.CellState.ACTIVE, current.cost], current_state, [depth])
		if current_state != Enums.CellState.START and current_state != Enums.CellState.END:
			grid.cells[current.pos] = [Enums.CellState.ACTIVE, current.cost]

		if current.pos == grid.end:
			final_node = current
			commit_step(Enums.StepType.LOG_MESSAGE, current.pos, "Target Reached! Cost: %d" % current.cost, null, [depth])
			break

		# Explore all 4 directions
		var directions = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
		for move_dir in directions:
			if move_dir == -current.dir:
				continue

			var next_pos = current.pos + move_dir
			var turn_cost = _calculate_turn_cost(current.dir, move_dir)
			var next_node = SearchNode.new(next_pos, move_dir, current.cost + 1 + turn_cost, current)
			_try_queue(pq, visited, next_node, grid.cells)

		# Trace: Visited
		current_state = grid.cells.get(current.pos, Enums.CellState.EMPTY)
		commit_step(Enums.StepType.GRID_UPDATE, current.pos, [Enums.CellState.VISITED, current.cost], current_state, [depth])
		if current_state[0] != Enums.CellState.START:
			grid.cells[current.pos] = [Enums.CellState.VISITED, current.cost]

	depth = pq.depth()
	# Reconstruct Path
	if final_node:
		var ptr = final_node
		while ptr:
			# Now we can trust the grid to hold the correct state (VISITED, QUEUED, etc.)
			var undo_state = grid.cells.get(ptr.pos, [Enums.CellState.EMPTY, 0])

			commit_step(Enums.StepType.GRID_UPDATE, ptr.pos, [Enums.CellState.ACTIVE, ptr.cost], undo_state, [depth])
			ptr = ptr.parent

func _try_queue(pq: PriorityQueue, visited: Dictionary, node: SearchNode, grid_data: Dictionary) -> void:
	if grid_data.get(node.pos, Enums.CellState.WALL) == Enums.CellState.WALL:
		return

	var dir_idx = _get_dir_index(node.dir)
	var key = Vector3i(node.pos.x, node.pos.y, dir_idx)

	if visited.has(key) and visited[key] <= node.cost:
		return

	pq.push(node.cost, node)
	var current_state = grid_data.get(node.pos, [Enums.CellState.EMPTY, 0])
	commit_step(Enums.StepType.GRID_UPDATE, node.pos, [Enums.CellState.QUEUED, node.cost], current_state, [pq.depth])
	if current_state[0] != Enums.CellState.START:
		grid_data[node.pos] = [Enums.CellState.QUEUED, node.cost]

# TODO: Make this adjustable on the fly, trigger a rewind and divergence resolution if changed mid-playback
func _calculate_turn_cost(current_dir: Vector2i, new_dir: Vector2i) -> int:
	if current_dir == new_dir:
		return 0
	if current_dir == -new_dir:
		return 2000
	return 1000

func _get_dir_index(dir: Vector2i) -> int:
	if dir == Vector2i.RIGHT: return 0
	if dir == Vector2i.DOWN: return 1
	if dir == Vector2i.LEFT: return 2
	if dir == Vector2i.UP: return 3
	return 0
