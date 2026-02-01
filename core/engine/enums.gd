class_name Enums

## Defines the visual state of a cell, mapping to the Kintsugi color palette.
enum CellState {
	EMPTY,      # Default/Charcoal Blue
	WALL,       # Obstacle
	START,      # Green (Source)
	END,        # Red (Target)
	VISITED,    # Blue (The Past)
	QUEUED,     # Purple (The Future)
	PROCESSING, # Orange (Friction/Heat)
	ACTIVE      # Yellow (The Spark/Current Pointer)
}

## Defines the type of operation a Step performs.
enum StepType {
	GRID_UPDATE,    # Change a cell's state
	CAMERA_MOVE,    # Pan/Zoom to a specific area
	LOG_MESSAGE,    # Update the UI log
	WAIT            # Pause for dramatic effect
}

## Standard metadata keys for Step payloads to ensure type safety.
const META_COST = "cost"
const META_HEURISTIC = "h_score"
const META_COORDINATES = "coords"