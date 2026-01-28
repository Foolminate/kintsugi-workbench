# Project Summary: Kintsugi Workbench
Goal: A Godot 4.5 portfolio project for visualizing complex algorithms (Advent of Code, Project Euler) using a high-fidelity, enterprise-safe aesthetic.
This is a living document, subject to updates and recommendations as the project, and it's needs, evolve.

## 1. Visual Identity (Kintsugi Midnight)
The theme is managed via a global ThemeManager.gd Singleton (Autoload) to ensure consistency across separate problem scenes.

**Color Palette Design Philosophy**
The Kintsugi Midnight palette is designed to balance aesthetic "soul" with technical clarity. It uses high-contrast focal points against a low-fatigue, desaturated background.

**Core Foundation**
- Background: Prussian Blue (#000E26) [Background]: Chosen to provide a "deeper" soul than pure black. It reduces eye strain during long coding sessions and provides a natural chromatic contrast that makes the Gold focal points appear to "glow" without needing high-brightness values.
- Grid: Charcoal Blue (#2B3B4F) [Grid]: Stepping away from neutral grey, this blue-leaning charcoal maintains the "Prussian" atmosphere. It is distinct enough to be a functional guide but subtle enough to recede once data is populated.

**The "Focal" Duality**
- Focus A: Metallic Gold (#DCAE1D) [Primary Focus]: Inspired by the Kintsugi art form. This is your "Value" color. It represents the solution, the successful path, or the current active head of an algorithm. Its warmth cuts through the cool background instantly
- Focus B: Amethyst Smoke (#BD84B3) [Secondary Focus]: A nod to the Pythonic "keyword" purple. It represents the "Logic" or "Process." Use this for search frontiers, auxiliary data, or secondary variables that influence the main solution.

**Data Typography**
- Text Primary: Alice Blue (#E4E8F1): A warm, high-legibility white for primary labels and coordinates.
- Text Secondary: Light Blue (#99C9D6): A desaturated, lower-contrast blue for headings or secondary metadata (e.g., frame rates, step counts, or "inactive" data) to prevent the UI from feeling cluttered.

**The Semantic Trio (Accents)**
These follow the standard "Status" color conventions but are shifted into a Pastel/Desaturated Gamut to ensure they don't clash with the primary Gold focal point:
- Green: Sage Green (#7CAB53): Success, start points, or "Safe" zones.
- Red: Dusty Mauve (#AF4650): Obstacles, end points, or "Danger" zones.
- Blue: Steel Blue (#81A1C1): Neutral search areas or "Visited" nodes.

## 2. Technical Architecture
- Grid Rendering: to be implemented with TileMapLayer. To avoid thousands of draw calls, the grid is rendered using a single-batch approach where the charcoal blue border is baked into the tile texture itself, allowing the GPU to render massive datasets (e.g., $100 \times 100$ AoC maps) at 60+ FPS. Note that border colors shouldn't change if the tile changes, but borders may need to change to show mouse hover.
- Logic Separation: Visualization scenes are standalone .tscn files, allowing the user to keep the workbench open while adding new problem-specific scenes without context pollution.
- Interactivity: to support mouse-to-grid coordinate translation using local_to_map() for "painting" data and testing visual feedback.
- Animation Philosophy: Targeted toward "3Blue1Brown" style smooth interpolation using Godot's Tween and Timer classes to visualize the "thinking" process of algorithms.

## 3. Roadmap
- [ ] Implement a grid visualiser
- [ ] Visualise basic logic in the grid
- [ ] Camera System: Implementation of a pan/zoom Camera2D to handle high-density maps.
- [ ] Data Bridge: Setup for streaming results from Python (JSON/WebSockets) into the Godot frontend.
- [ ] Deployment: Structured for Single-Threaded HTML5 export for frictionless internal corporate sharing.

## 4. Tools
- Windows 10
- PowerShell
- Godot 4.5
- GD Script
- Github

## 5. File Structure
kintsugi-workbench/
├── .godot/
├── .gitignore
├── project.godot
├── core/                    # The "Engine" (Immutable across problems)
│   ├── theme/
│   │   ├── ThemeManager.gd  # Autoload: Colors & UI Constants
│   │   └── MainTheme.tres   # Godot Theme resource
│   ├── components/          # Reusable UI Nodes
│   │   ├── GridVisualizer.gd
│   │   ├── GridVisualizer.tscn
│   │   └── CameraController.gd
│   └── utils/
│       └── DataBridge.gd    # Connect Python to Godot, possibly a JSON/WebSocket ingestion
├── problems/                # The "Content" (The Portfolio)
│   ├── advent_of_code/
│   │   ├── 2024/
│   │   │   ├── Day01/
│   │   │   │   ├── Day01_Solver.gd
│   │   │   │   └── Day01_Scene.tscn (Instances GridVisualizer)
│   ├── project_euler/
│   └── templates/           # Starter files for new problems
└── assets/
├── fonts/
└── branding/
