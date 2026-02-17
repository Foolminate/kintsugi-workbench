class_name MetaRecorder
extends RefCounted

var _manifest: SolverManifest
var _columns: Array[Array] = []
var _types: Array[Variant.Type] = []
var _num_metrics: int

func record(data: Array[Variant]) -> void:
	if data.size() != _num_metrics:
		push_error("Data size is %d, but manifest size is %d." % [data.size(), _num_metrics])
		return

	for i in range(_num_metrics):
		if typeof(data[i]) != _types[i]:
			push_error("Data type mismatch for metric '%s': expected %s, got %s" % [_manifest.metrics[i].label, str(_types[i]), str(typeof(data[i]))])
			_columns[i].append(_get_default_value(_types[i]))
		else:
			_columns[i].append(data[i])

func flush() -> Dictionary:
	var packed_columns: Dictionary = {}

	for i in range(_num_metrics):
		var metric_name = _manifest.metrics[i].label
		var type = _types[i]
		var data = _columns[i]

		match type:
			TYPE_BOOL: packed_columns[metric_name] = PackedByteArray(data)
			TYPE_INT: packed_columns[metric_name] = PackedInt64Array(data)
			TYPE_FLOAT: packed_columns[metric_name] = PackedFloat64Array(data)
			TYPE_STRING: packed_columns[metric_name] = PackedStringArray(data)
			_: packed_columns[metric_name] = data # Fallback to regular array for unsupported types
	return packed_columns

func _init(manifest: SolverManifest) -> void:
	_manifest = manifest
	_num_metrics = manifest.metrics.size()
	_types.resize(_num_metrics)
	_columns.resize(_num_metrics)

	for i in range(_num_metrics):
		var metric = manifest.metrics[i]
		_types[i] = metric.type

		match metric.type:
			TYPE_BOOL:
				var arr: Array[bool] = []
				_columns[i] = arr
			TYPE_INT:
				var arr: Array[int] = []
				_columns[i] = arr
			TYPE_FLOAT:
				var arr: Array[float] = []
				_columns[i] = arr
			TYPE_STRING:
				var arr: Array[String] = []
				_columns[i] = arr
			_: push_error("Unsupported metric type in MetaRecorder: %s" % str(metric.type))

func _get_default_value(type: Variant.Type) -> Variant:
	match type:
		TYPE_BOOL: return false
		TYPE_INT: return 0
		TYPE_FLOAT: return 0.0
		TYPE_STRING: return ""
	return null