extends Node

# Core palette: Kintsugi Midnight
const BACKGROUND: Color = Color('000E26')      # Prussian Blue
const FOCUS_A: Color = Color('DCAE1D')         # Metalic Gold
const FOCUS_B: Color = Color('BD84B3')         # Amethyst Smoke
const GRID: Color = Color('2B3B4F')            # Charcoal Blue
const TEXT_PRIMARY: Color = Color('E4E8F1')    # Alice Blue
const TEXT_SECONDARY: Color = Color('99C9D6')  # Light Blue

# Accents
const GREEN: Color = Color('7CAB53')           # Sage Green
const RED: Color = Color('AF4650')             # Dusty Mauve
const BLUE: Color = Color('81A1C1')            # Steel Blue

func _ready():
	RenderingServer.set_default_clear_color(BACKGROUND)
	print("ThemeManager initialized with Kintsugi Midnight palette.")
