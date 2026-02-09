# Project Summary: Kintsugi Workbench
Goal: A Godot 4.5 portfolio project for visualizing complex algorithms (Advent of Code, Project Euler) using a high-fidelity, enterprise-safe aesthetic.
This is a living document, subject to updates and recommendations as the project, and it's needs, evolve.

## 0. Instructions
- Give detailed node configuration instructions, explaininig where settings are in the inspector.
- Only provide code when asked for. Do not pollute the chat context with constantly refactored code.

## 1. Visual Identity (Kintsugi Midnight)
The theme is managed via a global ThemeManager.gd Singleton (Autoload) to ensure consistency across separate problem scenes. The design is juicy, using extra effects like glow, elastic smoothing, and other effects to create a high-end portfolio feel.

**Color Palette Design Philosophy**
The Kintsugi Midnight palette is designed to balance aesthetic "soul" with technical clarity. It uses high-contrast focal points against a low-fatigue, desaturated background.

**Core Foundation**
- Background: Deep Twilight (#060045) [Background]: Chosen to provide a "deeper" soul than pure black. It reduces eye strain during long coding sessions and provides a natural chromatic contrast that makes the Gold focal points appear to "glow" without needing high-brightness values.
- Grid: Charcoal Blue (#2B3B4F) [Grid]: Stepping away from neutral grey, this blue-leaning charcoal maintains the "Prussian" atmosphere. It is distinct enough to be a functional guide but subtle enough to recede once data is populated.

**The "Focal" Duality**
- Focus A: Metallic Gold (#DCAE1D) [Primary Focus]: Inspired by the Kintsugi art form. This is your "Value" color. It represents the solution, where the user is pointing, or essential information. Its warmth cuts through the cool background instantly
- Focus B: Rose Punch (#D93D83) [Secondary Focus]: A nod to the Pythonic "keyword" purple. It represents the "Logic" or "Process." Use this for search frontiers, auxiliary data, or secondary variables that influence the main solution.

**The Color Language**
These follow the standard "Status" color conventions but are shifted into a deeper Gamut to ensure they don't clash with the primary Gold or overwhelm the dark background.
- Green: Emerald depts (#255C43): The Source: Defines the Start Node or the "Initial State." It represents stability and validated data.
- Red: Mahogany Red (#A4161A): The Target: Defines the Goal Node or "Terminal State." It represents the solution found or a hard boundary/overflow.
- Blue: International Klein Blue (#2C279A): The Past: Tracks Explored Paths and "Visited Sets." It recedes into the background to provide a history of execution.
- Purple: Indigo (#54038A): The Future: Visualizes Heuristics and "Queued Nodes." Represents the algorithm’s predicted path or the "frontier" of discovery.
- Orange: Autumn Ember (#B85000): The Friction: Signals High-Cost Edges, "Heat," or "Flow Pressure." Used for active mutations or high-weight operations.
- Yelow: Harvest Gold (#D19200): The Spark: Marks the Active Pointer. High-luminance focus indicating exactly where the CPU is currently operating.

**Data Typography**
- Text Primary: Alice Blue (#E4E8F1): A warm, high-legibility white for primary labels and coordinates.
- Text Secondary: Light Blue (#99C9D6): A desaturated, lower-contrast blue for headings or secondary metadata (e.g., frame rates, step counts, or "inactive" data) to prevent the UI from feeling cluttered.

**Usage**
- **The Progress Gradient**: `BLUE` (Visited) $\rightarrow$ `PURPLE` (Queued) $\rightarrow$ `ORANGE` (Processing) $\rightarrow$ `YELLOW` (Current).
- The Narrative: High-contrast `YELLOW` paths connecting `GREEN` (Origin) to `RED` (Exit).
- The Aesthetic: Deep saturation against a dark navy canvas, utilizing "Glow" effects to mimic 3Blue1Brown mathematical elegance.

## 2. Technical Architecture
- Grid Rendering: to be implemented with TileMapLayer. To avoid thousands of draw calls, the grid is rendered using a single-batch approach where the charcoal blue border is baked into the tile texture itself, allowing the GPU to render massive datasets (e.g., $100 \times 100$ AoC maps) at 60+ FPS. Note that border colors shouldn't change if the tile changes, but borders may need to change to show mouse hover.
- Logic Separation: Visualization scenes are standalone .tscn files, allowing the user to keep the workbench open while adding new problem-specific scenes without context pollution.
- Interactivity: to support mouse-to-grid coordinate translation using local_to_map() for "painting" data and testing visual feedback.
- Animation Philosophy: Targeted toward "3Blue1Brown" style smooth interpolation using Godot's Tween and Timer classes to visualize the "thinking" process of algorithms.

## 3. Tools
- Windows 10
- PowerShell
- Godot 4.5
- GD Script
- VS Code
- Github

## 4. File Structure
kintsugi-workbench/
├── .godot/
├── .gitignore
├── project.godot
├── core/                        # The "Engine" (Immutable across problems)
│   ├── components/              # Reusable UI Nodes
│   │   ├── grid_visualizer.gd   # Renderer
│   │   ├── grid_visualizer.tscn
│   │   └── camera_controller.gd
│   ├── engine/
│   │   ├── step.gd
│   │   ├── orchestrator.gd
│   │   └── solver.gd
│   ├── theme/
│   │   ├── theme_manager.gd     # Autoload: Colors & UI Constants
│   │   └── main_theme.tres      # Godot Theme resource
│   └── utils/
│       └── data_bridge.gd       # Connect Python to Godot, possibly a JSON/WebSocket ingestion
├── problems/                    # The "Content" (The Portfolio)
│   ├── advent_of_code/
│   │   ├── aoc-2024/
│   │   │   ├── day01/
│   │   │   │   ├── day01_example.txt
│   │   │   │   ├── day01_puzzle.txt
│   │   │   │   ├── day01_solver.gd
│   │   │   │   └── day01_scene.tscn (Instances grid_visualizer)
│   ├── project-euler/
│   └── templates/               # Starter files for new problems
├── assets/
├── fonts/
└── branding/

## 5. Architecture: Orchestrator & Command Pattern
**Philosophy:** Decoupled execution using a "Hot-Swap" workflow. Stateless logic and reversible command logs ("Traces") will be used instead of fragile, live state management.

**Core Components:**
* **Orchestrator (Controller):** The central hub. Manages the master grid state and listens for input. On grid modification, it triggers a background re-solve and seamlessly swaps the resulting Trace (Hot-Swap).
* **Solver (Logic):** Pure, stateless reference class. `GridData` $\rightarrow$ `Trace` (Array of Steps).
* **Conductor (Playback):** The timeline manager. Holds the `Trace`, controls the cursor (index), and pushes updates to the View.
* **Visualizer (View):** Juicy rendering layer (TileMap/Control). Executes visual commands only.Detects the difference between Play (Interpolated) and Scrub (Instant/Fast) modes to maintain UI responsiveness.Must actively manage/kill tweens on a per-node basis to prevent animation conflicts during rapid timeline scrubbing.

**Data Protocol (`Step`):**
* **Structure:** A Command object containing `Target`, `Type`, and `Payload`.
* **Reversibility:** Each step stores an `UndoState` (visual snapshot of the target *before* execution), enabling O(1) scrubbing without logic reconstruction. Metadata is also stored to explain deeper detail like cost, weight, search depth, etc.

**Workflow:**
Input Event $\rightarrow$ Orchestrator updates Data $\rightarrow$ Solver Regenerates Trace $\rightarrow$ Conductor Syncs Timeline $\rightarrow$ Visualizer Renders.

## 6. Code Style and Preferences
- @onready is preferred to @export for node variables.
- Minimize nesting with gaurd clauses and method extraction
- Tabs are used for indentation—not spaces

## 6. Roadmap
- [x] Implement theme_manager.gd autoload.
- [x] Implement a grid visualiser.
- [x] Implement a camera system to zoom and pan.
- [x] Build the "engine":
  - [x] Step object: A problem state's delta trace element.
  - [x] Solver: Execute the algorithm and create traces.
  - [x] Conductor: Controls playback.
  - [x] Orchestrator: Listens to user input and coordinates the rest of the engine.
- [x] Visualise basic logic in the grid.
- [x] Implement basic UI controls, play, pause, stop, rewind, progress bar, increase/decrease playback speed.
- [x] Implement a theme resource to standardize UI elements.
- [ ] Establish a two-way API for different solvers and visualizers to show meta data and change parameters.
- [ ] Implement UI for metadata: active position, cost, search depth, queue length, etc.
- [ ] Data Bridge: Setup for streaming results from Python (JSON/WebSockets) into the Godot frontend.
- [ ] Deployment: Structured for Single-Threaded HTML5 export for frictionless internal corporate sharing.

## 7. Current Task
The following checklist is the focus. Review the checklist, investigate the existing code files, and then guide me through the next logical step of the implementation.

# Checklist: Solver ←→ Visualizer API

### Phase 1: The Core Data Pipeline (MVP)
*Goal: Establish the data flow from Solver to Trace without fancy UI.*
- [x] **Define `SolverManifest` Schema**
    - [x] **Parameters:** Dictionary of `{"name": {"type": TYPE_*, "default": val}}`.
        - *Scope:* Limit to `INT`, `FLOAT`, `BOOL`.
    - [x] **Global Metrics:** Dictionary of `{"key": "Label Name"}`.
        - *Scope:* Pure text output keys.
    - [x] **Spatial Columns:** Ordered Array of `{"label": "Name", "type": TYPE_*}`.
        - *Scope:* Defines the tuple structure for grid cells (e.g., `[G, H, Parent]`).
- [x] **Implement `PuzzleContext`**
    - [x] **Container:** Resource to hold raw input, the algorithms to parse and to solve it, the API for parameters and metadata.
- [ ] **Implement `MetaRecorder`**
    - [ ] **Storage:** Dictionary mapping `key` $\rightarrow$ `PackedArray`.
    - [ ] **Record:** `record_step(data_dict)` appends values to arrays.
    - [ ] **Flush:** Method to return the Dictionary of Arrays when solving finishes.
- [ ] **Update `Step` & Solver**
    - [ ] **Spatial Tuple:** Add `var spatial: Array` to `Step` class.
    - [ ] **Solver Loop:** Update solver to push tuples `[val1, val2]` to the Step, and global stats to `MetaRecorder`.
- [ ] **Update `Trace`**
    - [ ] **Storage:** Add `var meta_columns: Dictionary` to hold the arrays from the recorder.

### Phase 2: The Basic UI (MVP)
*Goal: Visualize the raw data with standard controls.*
- [ ] **Build `ParameterDock` (Inputs)**
    - [ ] **Loop:** Iterate manifest `parameters`.
    - [ ] **Create:** Simple `SpinBox` (numbers) or `CheckBox` (bools).
    - [ ] **Signal:** Emit `param_changed(key, value)` on change.
- [ ] **Build `MetadataHUD` (Global Outputs)**
    - [ ] **Setup:** Create one `Label` node per global metric key.
    - [ ] **Update:** On `Conductor.step_changed(i)`, set label text to `str(trace.meta_columns[key][i])`.
- [ ] **Build `TooltipManager` (Entity Outputs)**
    - [ ] **Cache:** Dictionary `current_spatial_state` (`Vector2i` $\rightarrow$ `Array`).
    - [ ] **Hover:** On mouse over, lookup tuple, join values with `\n`, and set Tooltip text.
- [ ] **Basic Re-Solve Loop**
    - [ ] **Trigger:** On `param_changed` signal.
    - [ ] **Action:** Update `PuzzleContext`, Trigger `Solver.solve()`, ui updates metadata as the trace is rewound to the divergence point.

### Phase 3: Extended Visuals (Future)
*Goal: Move from "Debug Text" to "Portfolio Polish".*
- [ ] **Enhanced `SolverManifest`**
    - [ ] **Ranges:** Add `[min, max, step]` to parameters for Sliders.
    - [ ] **Options:** Add `options: []` list for Dropdown menus.
    - [ ] **Visual Hints:** Add `display: "graph" | "bar"` and `color` to global metrics.
- [ ] **Advanced `MetadataHUD`**
    - [ ] **Graph Widget:** Render `PackedArray` data using `Line2D` or custom `draw()` calls.
    - [ ] **Bar Widget:** Render progress bars for percentage-based metrics.
- [ ] **Refined `ParameterDock`**
    - [ ] **Factory:** Support `HSlider`, `OptionButton`, and `ColorPicker`.

### Phase 4: Advanced Workflow (Future)
*Goal: Frictionless user experience for massive datasets.*
- [ ] **Smart Hot-Swapping**
    - [ ] **Signature Check:** Implement `PuzzleContext.get_hash()`.
    - [ ] **Diffing:** If only a visual parameter changed (e.g., color), do not re-solve logic.
    - [ ] **State Preservation:** When swapping traces, attempt to keep the Conductor at the same relative percentage or step index, rather than resetting to 0.