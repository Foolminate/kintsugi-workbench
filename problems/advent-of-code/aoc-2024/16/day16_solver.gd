extends Solver

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

func solve(grid: Grid) -> Array[Step]:
	var trace: Array[Step] = []
	var pq = PriorityQueue.new()
	var visited: Dictionary = {} # Key: Vector3i(x, y, dir_idx), Value: cost

	var start_pos = grid.start
	var end_pos = grid.end

	# Start facing East (1, 0)
	var start_dir = Vector2i.RIGHT
	var start_node = SearchNode.new(start_pos, start_dir, 0)
	pq.push(0, start_node)

	var final_node: SearchNode = null

	while not pq.is_empty():
		var current: SearchNode = pq.pop()

		var dir_idx = _get_dir_index(current.dir)
		var state_key = Vector3i(current.pos.x, current.pos.y, dir_idx)

		if visited.has(state_key) and visited[state_key] <= current.cost:
			continue
		visited[state_key] = current.cost

		# Trace: Current
		trace.append(create_step(Enums.StepType.GRID_UPDATE, current.pos, Enums.CellState.ACTIVE, grid.cells.get(current.pos, Enums.CellState.EMPTY)))

		if current.pos == end_pos:
			final_node = current
			trace.append(create_step(Enums.StepType.LOG_MESSAGE, current.pos, "Target Reached! Cost: %d" % current.cost, null))
			break

		# A. Move Forward
		var fwd_pos = current.pos + current.dir
		var next_node = SearchNode.new(fwd_pos, current.dir, current.cost + 1, current)
		_try_queue(pq, visited, next_node, trace, grid.cells)

		# B. Turn Clockwise
		var cw_dir = Vector2i(-current.dir.y, current.dir.x)
		var cw_node = SearchNode.new(current.pos, cw_dir, current.cost + 1000, current)
		_try_queue(pq, visited, cw_node, trace, grid.cells)

		# C. Turn Counter-Clockwise
		var ccw_dir = Vector2i(current.dir.y, -current.dir.x)
		var ccw_node = SearchNode.new(current.pos, ccw_dir, current.cost + 1000, current)
		_try_queue(pq, visited, ccw_node, trace, grid.cells)

		# Trace: Visited
		trace.append(create_step(Enums.StepType.GRID_UPDATE, current.pos, Enums.CellState.VISITED, Enums.CellState.ACTIVE))

	# Reconstruct Path
	if final_node:
		var ptr = final_node
		while ptr:
			trace.append(create_step(Enums.StepType.GRID_UPDATE, ptr.pos, Enums.CellState.ACTIVE, grid.cells.get(ptr.pos, Enums.CellState.EMPTY)))
			ptr = ptr.parent

	return trace

func _try_queue(pq: PriorityQueue, visited: Dictionary, node: SearchNode, trace: Array[Step], grid_data: Dictionary) -> void:
	if grid_data.get(node.pos, Enums.CellState.WALL) == Enums.CellState.WALL:
		return

	var dir_idx = _get_dir_index(node.dir)
	var key = Vector3i(node.pos.x, node.pos.y, dir_idx)

	if visited.has(key) and visited[key] <= node.cost:
		return
	# if visited.has(key):
	# 	return

	pq.push(node.cost, node)
	trace.append(create_step(Enums.StepType.GRID_UPDATE, node.pos, Enums.CellState.QUEUED, grid_data.get(node.pos, Enums.CellState.EMPTY)))

func _get_dir_index(dir: Vector2i) -> int:
	if dir == Vector2i.RIGHT: return 0
	if dir == Vector2i.DOWN: return 1
	if dir == Vector2i.LEFT: return 2
	if dir == Vector2i.UP: return 3
	return 0
