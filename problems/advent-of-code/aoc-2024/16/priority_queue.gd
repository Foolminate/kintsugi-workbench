class_name PriorityQueue
extends RefCounted

## A standard Binary Heap implementation for Dijkstra/A* algorithms.
## Stores items as [priority, data]. Min-heap by default (lowest priority first).

var _heap: Array = []

func depth() -> int:
	return _heap.size()

func push(priority: float, data: Variant) -> void:
	_heap.append([priority, data])
	_sift_up(_heap.size() - 1)

func pop() -> Variant:
	if _heap.is_empty():
		return null

	var result = _heap[0][1]
	var last = _heap.pop_back()

	if not _heap.is_empty():
		_heap[0] = last
		_sift_down(0)

	return result

func is_empty() -> bool:
	return _heap.is_empty()

func _sift_up(index: int) -> void:
	while index > 0:
		@warning_ignore("integer_division")
		var parent_index = (index - 1) / 2
		if _heap[index][0] < _heap[parent_index][0]:
			_swap(index, parent_index)
			index = parent_index
		else:
			break

func _sift_down(index: int) -> void:
	var size = _heap.size()
	while true:
		var left_child = 2 * index + 1
		var right_child = 2 * index + 2
		var smallest = index

		if left_child < size and _heap[left_child][0] < _heap[smallest][0]:
			smallest = left_child

		if right_child < size and _heap[right_child][0] < _heap[smallest][0]:
			smallest = right_child

		if smallest != index:
			_swap(index, smallest)
			index = smallest
		else:
			break

func _swap(i: int, j: int) -> void:
	var temp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = temp